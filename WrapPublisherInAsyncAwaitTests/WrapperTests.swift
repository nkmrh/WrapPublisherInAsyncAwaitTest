//
//  WrapperTests.swift
//  WrapPublisherInAsyncAwaitTests
//
//  Created by 中村　肇 on 2023/08/01.
//

import XCTest

@testable import WrapPublisherInAsyncAwait

class WrapperTests: XCTestCase {
  func testSuccessAndSuccess() async {
    Task {
      let w1 = Wrapper()
      let w2 = Wrapper()
      do {
        async let a = w1.doSomething(success: true)
        async let b = w2.doSomething(success: true)
        _ = try await (a, b)
        XCTAssertTrue(w1.receiveValueCalled)
        XCTAssertFalse(w1.receiveCompletionFailureCalled)
        XCTAssertTrue(w2.receiveValueCalled)
        XCTAssertFalse(w2.receiveCompletionFailureCalled)
      } catch {
        XCTFail()
      }
    }
  }

  func testFailAndFail() async {
    Task {
      let w1 = Wrapper()
      let w2 = Wrapper()
      do {
        async let a = w1.doSomething(success: false)
        async let b = w2.doSomething(success: false)
        _ = (try await a, try await b)
        XCTFail()
      } catch {
        XCTAssertFalse(w1.receiveValueCalled)
        XCTAssertTrue(w1.receiveCompletionFailureCalled)
        XCTAssertFalse(w2.receiveValueCalled)
        XCTAssertTrue(w2.receiveCompletionFailureCalled)
      }
    }
  }

  func testSuccessAndFail() async {
    Task {
      let w1 = Wrapper()
      let w2 = Wrapper()
      do {
        async let a = w1.doSomething(success: true)
        async let b = w2.doSomething(success: false)
        _ = (try await a, try await b)
        XCTFail()
      } catch {
        XCTAssertTrue(w1.receiveValueCalled)
        XCTAssertFalse(w2.receiveValueCalled)
        XCTAssertTrue(w2.receiveCompletionFailureCalled)
      }
    }
  }

  func testFailAndSuccess() async {
    Task {
      let w1 = Wrapper()
      let w2 = Wrapper()
      do {
        async let a = w1.doSomething(success: false)
        async let b = w2.doSomething(success: true)
        _ = (try await a, try await b)
        XCTFail()
      } catch {
        XCTAssertFalse(w1.receiveValueCalled)
        XCTAssertTrue(w1.receiveCompletionFailureCalled)
        XCTAssertTrue(w2.receiveValueCalled)
        XCTAssertFalse(w2.receiveCompletionFailureCalled)
      }
    }
  }
}
