//
//  TestHelpers.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import XCTest

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyValidHTTPResponse() -> HTTPURLResponse {
    httpResponse(code: 200)
}

func httpResponse(code: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!
}
