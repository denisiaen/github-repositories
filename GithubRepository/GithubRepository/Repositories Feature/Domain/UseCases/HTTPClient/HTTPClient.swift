//
//  HTTPClient.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import Foundation

public typealias HTTPResponse = (Data, HTTPURLResponse)

public protocol HTTPClient {
    func get(from url: URL) async throws -> HTTPResponse
}
