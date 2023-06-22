//
//  APIRepositoriesLoader.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public class APIRepositoriesLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}
