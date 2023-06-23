//
//  APIRepositoriesLoader.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import Foundation

public class APIRepositoriesLoader: RepositoriesLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadRepositoriesResult
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() async throws -> [RepositoryItem] {
        guard let (data, response) = try? await client.get(from: url) else {
            throw Error.connectivity
        }
        
        return try RepositoriesMapper.map(data, response)
    }
}
