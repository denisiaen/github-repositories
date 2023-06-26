//
//  APIImageLoaderTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import XCTest
import GithubRepository

protocol ImageDataLoader {
    
}

struct ImageLoadError: Error {}


class APIImageDataLoader {
    private let client: HTTPClient
    private let url: URL
    
    
    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    func load() async throws -> Data {
        do {
            let _ = try await client.get(from: url)
            return Data()
        } catch {
            throw ImageLoadError()
        }
    }
}

final class APIImageDataLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() async throws {
        let url = URL(string: "https://a-url")!
        let (sut, client) = makeSUT()

        _ = try await sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() async throws {
        let url = URL(string: "https://a-url")!
        let (sut, client) = makeSUT()

        _ = try await sut.load()
        _ = try await sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() async throws {
        let (sut, _) = makeSUT(result: .failure(anyNSError()))
                
        await expect(sut, toThrowError: ImageLoadError.self)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url")!, result: Result<(Data, HTTPURLResponse), Error> = .success((Data(), HTTPURLResponse())), file: StaticString = #filePath, line: UInt = #line) -> (sut: APIImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy(result: result)
        let sut = APIImageDataLoader(client: client, url: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect<E: Error>(_ sut: APIImageDataLoader, toThrowError expectedError: E.Type, file: StaticString = #filePath, line: UInt = #line) async {
        do {
            _ = try await sut.load()
            XCTFail("Expected to throw \(expectedError)", file: file, line: line)
        } catch {
            XCTAssertTrue(error is E, file: file, line: line)
        }
    }
}

private class HTTPClientSpy: HTTPClient {
    private(set) var requestedURLs = [URL]()
    
    let result: Result<(Data, HTTPURLResponse), Error>
    
    init(result: Result<(Data, HTTPURLResponse), Error>) {
        self.result = result
    }
    
    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        requestedURLs.append(url)
        return try result.get()
    }
}
