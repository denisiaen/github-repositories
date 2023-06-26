//
//  APIRepositoriesLoaderTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import XCTest
import GithubRepository

final class APIRepositoriesLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() async throws {
        let url = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT(url: url, result: .success(anyValidResponse()))

        _ = try await sut.load()

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() async throws {
        let url = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT(url: url, result: .success(anyValidResponse()))
        
        _ = try await sut.load()
        _ = try await sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() async throws {
        let (sut, _) = makeSUT(result: .failure(anyNSError()))
        
        await expect(sut, toThrowError: .connectivity)
    }

    func test_load_deliversErrorOnNon200HTTPResponse() async throws {
        let samples = [199, 201, 300, 400, 500]
        
        for code in samples {
            let non200Response = (Data(), httpResponse(code: code))
            let (sut, _) = makeSUT(result: .success(non200Response))
            await expect(sut, toThrowError: .invalidData)
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() async throws {
        let invalidJSON = Data("invalid data".utf8)
        let (sut, _) = makeSUT(result: .success((invalidJSON, anyValidHTTPResponse())))
        
        await expect(sut, toThrowError: .invalidData)
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() async throws {
        let (sut, _) = makeSUT(result: .success(anyValidResponse()))
        
        await expect(sut, toSucceedWith: [])
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() async throws {
        let item1 = RepositoryItem(id: 1, userName: "A Name", imageURL: URL(string: "http://a-url.com")!, repositoryName: "Repo Name", description: nil, language: nil, stars: nil)

        let item2 = RepositoryItem(id: 2, userName: "A Name", imageURL: URL(string: "http://a-url.com")!, repositoryName: "Repo Name", description: "description", language: "language", stars: 3)

        let itemsJSON = """
        {
            "items": [
                {
                    "id": \(item1.id),
                    "name": "\(item1.repositoryName)",
                    "owner": {
                        "login": "\(item1.userName)",
                        "avatar_url": "\(item1.imageURL)"
                    }
                },
                {
                    "id": \(item2.id),
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
        
        let (sut, _) = makeSUT(result: .success((itemsJSON, anyValidHTTPResponse())))

        await expect(sut, toSucceedWith: [item1, item2])
    }
        
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url")!, result: Result<(Data, HTTPURLResponse), Error> = .success((Data(), HTTPURLResponse())), file: StaticString = #filePath, line: UInt = #line) -> (sut: APIRepositoriesLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy(result: result)
        let sut = APIRepositoriesLoader(client: client, url: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: APIRepositoriesLoader, toSucceedWith expectedItems: [RepositoryItem], file: StaticString = #filePath, line: UInt = #line) async {
        do {
            let response = try await sut.load()
            XCTAssertEqual(response, expectedItems, file: file, line: line)
        } catch {
            XCTFail("Expected success, got error: \(error)", file: file, line: line)
        }
    }
    
    private func expect(_ sut: APIRepositoriesLoader, toThrowError expectedError: APIRepositoriesLoader.Error, file: StaticString = #filePath, line: UInt = #line) async {
        do {
            _ = try await sut.load()
            XCTFail("Expected error: \(expectedError)", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? APIRepositoriesLoader.Error, expectedError, file: file, line: line)
        }
    }
    
    private func anyValidResponse() -> (Data, HTTPURLResponse) {
        (emptyItemsJSON(), anyValidHTTPResponse())
    }
    
    private func emptyItemsJSON() -> Data {
        Data("{\"items\": []}".utf8)
    }
}

