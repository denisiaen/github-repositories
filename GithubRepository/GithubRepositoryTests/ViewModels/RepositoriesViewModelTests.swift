//
//  RepositoriesViewModelTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import XCTest
import GithubRepository

public class RepositoriesViewModel: ObservableObject {
    
    private let repositoriesLoader: RepositoriesLoader
    
    @Published public var repositoryItems = [RepositoryItem]()
    @Published public var isLoading = false
    @Published public var error: Error?
    
    public init(repositoriesLoader: RepositoriesLoader) {
        self.repositoriesLoader = repositoriesLoader
    }
    
    @MainActor
    public func viewDidAppear() async {
        do {
            _ = try await repositoriesLoader.load()
        } catch {
            
        }
    }
}

final class RepositoriesViewModelTests: XCTestCase {
    
    func test_init_deliversEmptyList() {
        let (sut, _) = makeSUT()
        
        XCTAssertTrue(sut.repositoryItems.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func test_viewDidAppear_invokesLoadRepositories() async {
        let (sut, loader) = makeSUT()
        
        await sut.viewDidAppear()
        
        XCTAssertEqual(loader.invokedLoadCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (viewModel: RepositoriesViewModel, loader: RepositoriesLoaderSpy) {
        let repositoriesLoaderSpy = RepositoriesLoaderSpy()
        let sut = RepositoriesViewModel(repositoriesLoader: repositoriesLoaderSpy)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, repositoriesLoaderSpy)
    }
}

private class RepositoriesLoaderSpy: RepositoriesLoader {
    var invokedLoadCount = 0
    
    func load() async throws -> [RepositoryItem] {
        invokedLoadCount += 1
        return []
    }
}
