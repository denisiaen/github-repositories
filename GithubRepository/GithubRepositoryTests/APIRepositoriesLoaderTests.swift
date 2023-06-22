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
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let clientError = NSError(domain: "any-error", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("invalid data".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = RepositoryItem(id: UUID(), userName: "A Name", imageURL: URL(string: "http://a-url.com")!, repositoryName: "Repo Name", description: nil, language: nil, stars: nil)
        
        let item2 = RepositoryItem(id: UUID(), userName: "A Name", imageURL: URL(string: "http://a-url.com")!, repositoryName: "Repo Name", description: "description", language: "language", stars: 3)
        
        let itemsJSON = """
        {
            "items": [
                {
                    "id": "\(item1.id.uuidString)",
                    "name": "\(item1.repositoryName)",
                    "owner": {
                        "login": "\(item1.userName)",
                        "avatar_url": "\(item1.imageURL)"
                    }
                },
                {
                    "id": "\(item2.id.uuidString)",
                    "name": "\(item2.repositoryName)",
                    "description": "\(item2.description ?? "")",
                    "language": "\(item2.language ?? "")",
                    "stargazers_count": \(item2.stars ?? 0),
                    "owner": {
                        "login": "\(item2.userName)",
                        "avatar_url": "\(item2.imageURL)"
                    }
                }
            ]
        }
        """.data(using: .utf8)!
        
        expect(sut, toCompleteWith: .success([item1, item2])) {
            client.complete(withStatusCode: 200, data: itemsJSON)
        }
    }
        
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: APIRepositoriesLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = APIRepositoriesLoader(client: client, url: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: APIRepositoriesLoader, toCompleteWith result: APIRepositoriesLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [APIRepositoriesLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        // when every test finishes running, then this block is invoked
        addTeardownBlock { [weak instance] in
            // make sure instance is gonna be nil after each test runs
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }

}
