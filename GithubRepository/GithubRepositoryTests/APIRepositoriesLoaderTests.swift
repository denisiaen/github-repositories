//
//  APIRepositoriesLoaderTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import XCTest

class HTTPClient {
    var requestedURL: URL?
}

class APIRepositoriesLoader {
    
}

final class APIRepositoriesLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        let _ = APIRepositoriesLoader()
        
        XCTAssertNil(client.requestedURL)
    }

}
