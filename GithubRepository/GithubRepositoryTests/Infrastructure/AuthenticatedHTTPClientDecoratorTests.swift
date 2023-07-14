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
    
    init(decoratee: HTTPClient, service: TokenService) {
        self.decoratee = decoratee
        self.service = service
    }
    
    func get(from request: HTTPRequest) async throws -> HTTPResponse {
        let token = try await service.getToken()
        var signedRequest = request
        signedRequest.header = ["token": token]
        return try await decoratee.get(from: signedRequest)
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
