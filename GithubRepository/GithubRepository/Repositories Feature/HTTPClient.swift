//
//  HTTPClient.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}
