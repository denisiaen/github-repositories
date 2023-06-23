//
//  URLSessionHTTPClientTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import XCTest
import GithubRepository

public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
    public func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
}

class URLSessionHTTPClient: HTTPClient {
    private let session: URLSessionProtocol
        
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func get(from url: URL) async throws -> HTTPResponse {
        let urlRequest = URLRequest(url: url)
        let (data, urlResponse) = try await session.data(for: urlRequest)
               
        return (data, urlResponse as! HTTPURLResponse)
    }
}

public struct UnsupportedURLResponseError: Error {}

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_init_doesNotPerformGETRequest() {
        let (_, session) = makeSUT()
        
        XCTAssertTrue(session.requests.isEmpty)
    }
    
    func test_getFromURL_performsGETRequestWithURL() async throws {
        let url = anyURL()
        let anyValidResponse = (Data(), HTTPURLResponse())
        let (sut, session) = makeSUT(result: .success(anyValidResponse))
        
        _ = try await sut.get(from: url)
        
        XCTAssertEqual(session.requests.count, 1)
        XCTAssertEqual(session.requests.first?.url, url)
        XCTAssertEqual(session.requests.first?.httpMethod, "GET")
    }
    

    // MARK: - Helpers
    
    private func makeSUT(
        result: Result<(Data, URLResponse), Error> = .success(anyValidResponse())
    ) -> (sut: URLSessionHTTPClient, session: URLSessionProtocolStub) {
        let sessionStub = URLSessionProtocolStub(result: result)
        let sut = URLSessionHTTPClient(session: sessionStub)

        return (sut, sessionStub)
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
}

private func anyValidResponse() -> (Data, HTTPURLResponse) {
    (Data(), anyValidResponse())
}

private func anyValidResponse() -> HTTPURLResponse {
    httpResponse(code: 200)
}

private func httpResponse(code: Int) -> HTTPURLResponse {
    HTTPURLResponse(url: URL(string: "http://any-url.com")!, statusCode: code, httpVersion: nil, headerFields: nil)!
}

private class URLSessionProtocolStub: URLSessionProtocol {
    private let result: Result<(Data, URLResponse), Error>
    private(set) var requests = [URLRequest]()
    
    init(result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        return try result.get()
    }
}
