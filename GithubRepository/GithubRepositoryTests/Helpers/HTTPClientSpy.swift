//
//  HTTPClientSpy.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import GithubRepository
import Foundation

class HTTPClientSpy: HTTPClient {
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
