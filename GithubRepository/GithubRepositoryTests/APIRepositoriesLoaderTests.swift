//
//  APIRepositoriesLoaderTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import XCTest
import GithubRepository

class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success(data, response))
    }
}

final class APIRepositoriesLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "any-error", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJSON = Data("invalid data".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
        
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url")!) -> (sut: APIRepositoriesLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = APIRepositoriesLoader(client: client, url: url)
        return (sut, client)
    }
    
    private func expect(_ sut: APIRepositoriesLoader, toCompleteWithError error: APIRepositoriesLoader.Error, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [APIRepositoriesLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [.failure(error)], file: file, line: line)
    }
}
