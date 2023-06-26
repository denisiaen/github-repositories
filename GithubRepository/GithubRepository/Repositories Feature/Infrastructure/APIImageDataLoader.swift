//
//  APIImageDataLoader.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import Foundation

public class APIImageDataLoader: ImageDataLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case failed
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() async throws -> Data {
        guard let (data, response) = try? await client.get(from: url) else {
            throw Error.failed
        }
        
        return try ImageDataMapper.map(data, from: response)
    }
}
