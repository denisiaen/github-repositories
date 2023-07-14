//
//  APIImageLoaderTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import XCTest
import GithubRepository

final class APIImageDataLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requests.isEmpty)
    }
    
    func test_load_requestsDataFromURL() async throws {
        let url = URL(string: "https://a-url")!
        let (sut, client) = makeSUT()

        _ = try await sut.load(url: url)
        
        XCTAssertEqual(client.requests.map{ $0.url }, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() async throws {
        let url = URL(string: "https://a-url")!
        let (sut, client) = makeSUT()

        _ = try await sut.load(url: url)
        _ = try await sut.load(url: url)
        
        XCTAssertEqual(client.requests.map{ $0.url }, [url, url])
    }
    
    func test_load_throwsErrorOnClientError() async {
        let (sut, _) = makeSUT(result: .failure(anyNSError()))
                
        await expect(sut, toThrowError: .failed)
    }
    
    func test_load_throwsErrorOnNon200HTTPResponse() async {
        let samples = [199, 201, 300, 400, 500]
        
        for code in samples {
            let non200Response = (Data(), httpResponse(code: code))
            let (sut, _) = makeSUT(result: .success(non200Response))
            await expect(sut, toThrowError: .invalidData)
        }
    }
    
    func test_load_throwsErrorOn200HTTPResponseWithEmptyData() async {
        let (sut, _) = makeSUT(result: .success((Data(), anyValidHTTPResponse())))
        
        await expect(sut, toThrowError: .invalidData)
    }
    
    func test_load_deliversReceivedNonEmptyDataOn200HTTPResponse() async {
        let nonEmptyData = Data("non-empty data".utf8)
        let (sut, _) = makeSUT(result: .success((nonEmptyData, anyValidHTTPResponse())))
        
        await expect(sut, toSucceedWith: nonEmptyData)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url")!, result: Result<(Data, HTTPURLResponse), Error> = .success((anyData(), HTTPURLResponse())), file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy(result: result)
        let sut = APIImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: ImageDataLoader, toSucceedWith data: Data, file: StaticString = #filePath, line: UInt = #line) async {
        do {
            let result = try await sut.load(url: anyURL())
            XCTAssertEqual(result, data, file: file, line: line)
        } catch {
            XCTFail("Expected success, got error: \(error)", file: file, line: line)
        }
    }
    
    private func expect(_ sut: ImageDataLoader, toThrowError expectedError: APIImageDataLoader.Error, file: StaticString = #filePath, line: UInt = #line) async {
        do {
            _ = try await sut.load(url: anyURL())
            XCTFail("Expected to throw error: \(expectedError)", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? APIImageDataLoader.Error, expectedError, file: file, line: line)
        }
    }
}
