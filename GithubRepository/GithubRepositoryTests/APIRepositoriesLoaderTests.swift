//
//  APIRepositoriesLoaderTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import XCTest
import GithubRepository

class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, completion: (Error) -> Void)]()
    
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (Error) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(error)
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
        
        var receivedError = [APIRepositoriesLoader.Error]()
        sut.load { error in
            receivedError.append(error)
        }
        
        let clientError = NSError(domain: "any-error", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(receivedError, [.connectivity])
    }
        
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url")!) -> (sut: APIRepositoriesLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = APIRepositoriesLoader(client: client, url: url)
        return (sut, client)
    }
}
