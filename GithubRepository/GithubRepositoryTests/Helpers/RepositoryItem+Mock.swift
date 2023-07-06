//
//  RepositoryItem+Mock.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 06.07.2023.
//

import Foundation
import GithubRepository

func anyRepositoryItem() -> RepositoryItem {
    RepositoryItem(id: 1, userName: "A name", imageURL: URL(string: "http://url")!, repositoryName: "A repo", description: nil, language: nil, stars: nil)
}
