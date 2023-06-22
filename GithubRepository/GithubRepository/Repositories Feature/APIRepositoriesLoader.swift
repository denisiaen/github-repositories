//
//  APIRepositoriesLoader.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public class APIRepositoriesLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([RepositoryItem])
        case failure(Error)
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .failure:
                completion(.failure(.connectivity))
            case let .success(data, response):
                if response.statusCode == 200, let _ = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success([]))
                } else {
                    completion(.failure(Error.invalidData))
                }
            }
        }
    }
}

private struct Root: Decodable {
    let items: [Repository]
        
    struct Repository: Decodable {
        enum CodingKeys: String, CodingKey {
            case id
            case owner
            case repositoryName = "name"
            case description
            case language
            case stars = "stargazers_count"
        }
        
        let id: UUID
        let owner: Owner
        let repositoryName: String
        let description: String?
        let language: String?
        let stars: Int?
        
        var repositoryItem: RepositoryItem {
            RepositoryItem(id: id, userName: owner.userName, imageURL: owner.imageURL, repositoryName: repositoryName, description: description, language: language, stars: stars)
        }
    }
    
    struct Owner: Decodable {
        enum CodingKeys: String, CodingKey {
            case userName = "login"
            case imageURL = "avatar_url"
        }
        
        let userName: String
        let imageURL: URL
    }
}
