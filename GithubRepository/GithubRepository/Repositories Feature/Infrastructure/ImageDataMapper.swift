//
//  ImageDataMapper.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import Foundation

public final class ImageDataMapper {
    private init() {}

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw APIImageDataLoader.Error.invalidData
        }
        
        return data
    }
}
