//
//  Function.swift
//  WrapPublisherInAsyncAwait
//
//  Created by 中村　肇 on 2023/08/01.
//

import Foundation
import Combine

class Wrapper {
  var receiveCompletionFailureCalled = false
  var receiveValueCalled = false
  var isCancelled = false

  private func doSomething(success: Bool) -> AnyPublisher<Void, Error> {
    Future { promise in
      DispatchQueue.global().async {
        if success {
          promise(.success(()))
        } else {
          promise(.failure(URLError(.badURL)))
        }
      }
    }
    .eraseToAnyPublisher()
  }

  func doSomething(success: Bool) async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      isCancelled = Task.isCancelled
      doSomething(success: success)
        .subscribe(
          Subscribers.Sink(
            receiveCompletion: { [weak self] completion in
              switch completion {
              case .finished:
                break
              case let .failure(error):
                self?.receiveCompletionFailureCalled = true
                continuation.resume(throwing: error)
              }
            },
            receiveValue: { [weak self] value in
              self?.receiveValueCalled = true
              continuation.resume(returning: value)
            }
          )
        )
    }
  }
}
