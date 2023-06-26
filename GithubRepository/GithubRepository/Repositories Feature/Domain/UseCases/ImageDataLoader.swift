//
//  ImageDataLoader.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import Foundation

public protocol ImageDataLoader {
    func load(url: URL) async throws -> Data
}
