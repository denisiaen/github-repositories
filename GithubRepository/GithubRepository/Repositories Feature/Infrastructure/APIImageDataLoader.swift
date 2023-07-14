//
//  APIImageDataLoader.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import Foundation

public class APIImageDataLoader: ImageDataLoader {
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case failed
        case invalidData
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func load(url: URL) async throws -> Data {
        guard let (data, response) = try? await client.get(from: HTTPRequest(url: url)) else {
            throw Error.failed
        }
        
        return try ImageDataMapper.map(data, from: response)
    }
}


