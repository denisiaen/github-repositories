//
//  RepositoryItem.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import Foundation

public struct RepositoryItem: Equatable {
    public let id: UUID
    public let userName: String
    public let imageURL: URL
    public let repositoryName: String
    public let description: String?
    public let language: String?
    public let stars: Int?
    
    public init(id: UUID, userName: String, imageURL: URL, repositoryName: String, description: String?, language: String?, stars: Int?) {
        self.id = id
        self.userName = userName
        self.imageURL = imageURL
        self.repositoryName = repositoryName
        self.description = description
        self.language = language
        self.stars = stars
    }
}
