//
//  HTTPClient.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import Foundation

public typealias HTTPResponse = (Data, HTTPURLResponse)

public protocol Request {
    var url: URL { get }
    var header: [String: String]? { get }
}

public protocol HTTPClient {
    func get(from request: Request) async throws -> HTTPResponse
}

public struct HTTPRequest: Request {
    public let url: URL
    public let header: [String : String]?
    
    public init(url: URL, header: [String: String]? = nil) {
        self.url = url
        self.header = header
    }
}
