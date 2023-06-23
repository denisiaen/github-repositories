//
//  URLSessionHTTPClient.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSessionProtocol
        
    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    public func get(from url: URL) async throws -> HTTPResponse {
        let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        
        let (data, urlResponse) = try await session.data(for: urlRequest)
        
        guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
            throw UnsupportedURLResponseError()
        }
        
        return (data, httpUrlResponse)
    }
}

public struct UnsupportedURLResponseError: Error {}
