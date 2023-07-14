//
//  HTTPClientSpy.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import GithubRepository
import Foundation

class HTTPClientSpy: HTTPClient {
    private(set) var requests = [Request]()
    
    let result: Result<(Data, HTTPURLResponse), Error>
    
    init(result: Result<(Data, HTTPURLResponse), Error> = .success((anyData(), anyValidHTTPResponse()))) {
        self.result = result
    }
    
    func get(from request: Request) async throws -> HTTPResponse {
        requests.append(request)
        return try result.get()
    }
}
