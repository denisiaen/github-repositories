//
//  HTTPClient.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import Foundation

public typealias HTTPResponse = (Data, HTTPURLResponse)

public protocol HTTPClient {
    func get(from request: HTTPRequest) async throws -> HTTPResponse
}

public struct HTTPRequest: Equatable {
    public let url: URL
    public var header: [String : String]?
    
    public init(url: URL, header: [String: String]? = nil) {
        self.url = url
        self.header = header
    }
}
