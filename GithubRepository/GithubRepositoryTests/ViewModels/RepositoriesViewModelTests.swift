//
//  RepositoriesViewModelTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import XCTest
import GithubRepository

public class RepositoriesViewModel: ObservableObject {
    
    @Published public var repositoryItems = [RepositoryItem]()
    @Published public var isLoading = false
    @Published public var error: Error?
}

final class RepositoriesViewModelTests: XCTestCase {
    
    func test_init_deliversEmptyList() {
        let sut = makeSUT()
        
        XCTAssertTrue(sut.repositoryItems.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RepositoriesViewModel {
        let sut = RepositoriesViewModel()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
