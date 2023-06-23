//
//  XCTestCase+MemoryLeakTracking.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        // when every test finishes running, then this block is invoked
        addTeardownBlock { [weak instance] in
            // make sure instance is gonna be nil after each test runs
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
