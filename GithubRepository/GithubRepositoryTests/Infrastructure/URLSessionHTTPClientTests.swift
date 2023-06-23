//
//  URLSessionHTTPClientTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import XCTest
import GithubRepository

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_init_doesNotPerformGETRequest() {
        let (_, session) = makeSUT()
        
        XCTAssertTrue(session.requests.isEmpty)
    }
    
    func test_getFromURL_performsGETRequestWithURL() async throws {
        let url = anyURL()
        let (sut, session) = makeSUT(result: .success(anyValidResponse()))
        
        _ = try await sut.get(from: url)
        
        XCTAssertEqual(session.requests.count, 1)
        XCTAssertEqual(session.requests.first?.url, url)
        XCTAssertEqual(session.requests.first?.httpMethod, "GET")
    }
    
    func test_getFromURL_failsOnRequestError() async throws {
        let requestError = anyNSError()
        let (sut, _) = makeSUT(result: .failure(requestError))
        
        do {
            _ = try await sut.get(from: anyURL())
            XCTFail("Expected error \(requestError)")
        } catch {
            XCTAssertEqual((error as NSError?)?.domain, requestError.domain)
            XCTAssertEqual((error as NSError?)?.code, requestError.code)
        }
    }
    
    func test_getFromURL_failsOnNonHTTPURLResponse() async throws {
        let url = anyURL()
        let invalidResponse = (Data(), nonHTTPURLResponse())
        let (sut, _) = makeSUT(result: .success(invalidResponse))
        
        do {
            _ = try await sut.get(from: url)
            XCTFail("Expected to throw error")
        } catch {
            XCTAssertTrue(error is UnsupportedURLResponseError)
        }
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() async throws {
        let data = anyData()
        let response = anyValidHTTPResponse()
        let (sut, _) = makeSUT(result: .success((data, response)))
        
        let receivedValues = try await sut.get(from: anyURL())
        
        XCTAssertEqual(receivedValues.0, data)
        XCTAssertEqual(receivedValues.1.url, response.url)
        XCTAssertEqual(receivedValues.1.statusCode, response.statusCode)
    }

    // MARK: - Helpers
    
    private func makeSUT(
        result: Result<(Data, URLResponse), Error> = .success(anyValidResponse()), file: StaticString = #filePath, line: UInt = #line
    ) -> (sut: URLSessionHTTPClient, session: URLSessionProtocolStub) {
        let sessionStub = URLSessionProtocolStub(result: result)
        let sut = URLSessionHTTPClient(session: sessionStub)
        trackForMemoryLeaks(sessionStub, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, sessionStub)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyData() -> Data {
        Data("any data".utf8)
    }
}

private func anyValidResponse() -> (Data, HTTPURLResponse) {
    (Data(), anyValidHTTPResponse())
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
