//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 14.07.2023.
//

import XCTest
import GithubRepository

class AuthenticatedHTTPClientDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let service: TokenService
    
    public enum Error: Swift.Error {
        case failedToAuthenticate
    }
    
    init(decoratee: HTTPClient, service: TokenService) {
        self.decoratee = decoratee
        self.service = service
    }
    
    func get(from request: HTTPRequest) async throws -> HTTPResponse {
        do {
            let token = try await service.getToken()
            var signedRequest = request
            signedRequest.header = ["token": token]
            return try await decoratee.get(from: signedRequest)
        } catch {
            throw Error.failedToAuthenticate
        }
    }
}

final class AuthenticatedHTTPClientDecoratorTests: XCTestCase {

    func test_getRequest_withSuccessfulTokenRequest_signsRequestWithToken() async throws {
        let token = "any token"
        let unsignedRequest = makeTestRequest()
        let signedRequest = unsignedRequest.signed(with: token)
        let client = HTTPClientSpy()
        let service = TokenServiceSpy(.success(token))
        
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, service: service)
        
        _ = try await sut.get(from: unsignedRequest)
        
        XCTAssertEqual(client.requests, [signedRequest])
    }
    
    func test_getRequest_withSuccessfulTokenRequest_completesWithDecorateeResult() async throws {
        let values = (anyData(), anyValidHTTPResponse())
        let client = HTTPClientSpy(result: .success(values))
        let service = TokenServiceSpy(.success("any token"))
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, service: service)
        
        let receivedValues = try await sut.get(from: makeTestRequest())
        
        XCTAssertEqual(receivedValues.0, values.0)
        XCTAssertEqual(receivedValues.1, values.1)
    }
    
    func test_sendRequest_withFailedTokenRequests_Fails() async throws {
        let client = HTTPClientSpy()
        let service = TokenServiceSpy(.failure(anyNSError()))
        
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client, service: service)
        
        do {
            _ = try await sut.get(from: makeTestRequest())
            XCTFail("Expected error, got success instead")
        } catch {
            XCTAssertEqual(client.requests, [])
            XCTAssertEqual(error as? AuthenticatedHTTPClientDecorator.Error, .failedToAuthenticate)
        }
    }

    // MARK: - Helpers
    
    private func makeTestRequest() -> HTTPRequest {
        HTTPRequest(url: anyURL(), header: [:])
    }
}

private extension HTTPRequest {
    func signed(with token: String) -> HTTPRequest {
        HTTPRequest(url: url, header: ["token": token])
    }
}

protocol TokenService {
    func getToken() async throws -> String
}

final class TokenServiceSpy: TokenService {
    private let result: Result<String, Error>
    
    init(_ result: Result<String, Error> = .success("")) {
        self.result = result
    }
    
    func getToken() async throws -> String {
        try result.get()
    }
}
