//
//  RepositoriesMapper.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import Foundation

public final class RepositoriesMapper {
    private struct Root: Decodable {
        private let items: [Repository]
        
        var repositories: [RepositoryItem] {
            items.map { $0.repositoryItem }
        }
        
        struct Repository: Decodable {
            enum CodingKeys: String, CodingKey {
                case id
                case owner
                case repositoryName = "name"
                case description
                case language
                case stars = "stargazers_count"
            }
            
            private let id: Int
            private let owner: Owner
            private let repositoryName: String
            private let description: String?
            private let language: String?
            private let stars: Int?
            
            var repositoryItem: RepositoryItem {
                RepositoryItem(id: id, userName: owner.userName, imageURL: owner.imageURL, repositoryName: repositoryName, description: description, language: language, stars: stars)
            }
        }
        
        private struct Owner: Decodable {
            enum CodingKeys: String, CodingKey {
                case userName = "login"
                case imageURL = "avatar_url"
            }
            
            let userName: String
            let imageURL: URL
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    private init() {}
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RepositoryItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw APIRepositoriesLoader.Error.invalidData
        }
        
        return root.repositories
    }
}
