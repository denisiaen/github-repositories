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
            self.error = error
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
    
    func test_viewDidAppear_deliversErrorOnRepositoriesLoadError() async {
        let (sut, _) = makeSUT(repositoriesLoaderResult: .failure(anyNSError()))
        
        await sut.viewDidAppear()
        
        XCTAssertNotNil(sut.error)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        repositoriesLoaderResult: Result<[RepositoryItem], Error> = .success([anyRepositoryItem()]), file: StaticString = #filePath, line: UInt = #line) -> (viewModel: RepositoriesViewModel, loader: RepositoriesLoaderStub
        ) {
        let repositoriesLoaderStub = RepositoriesLoaderStub(result: repositoriesLoaderResult)
        let sut = RepositoriesViewModel(repositoriesLoader: repositoriesLoaderStub)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, repositoriesLoaderStub)
    }
}

private func anyRepositoryItem() -> RepositoryItem {
    RepositoryItem(id: UUID(), userName: "A name", imageURL: URL(string: "http://url")!, repositoryName: "A repo", description: nil, language: nil, stars: nil)
}

private class RepositoriesLoaderStub: RepositoriesLoader {
    var invokedLoadCount = 0
    
    private var result: Result<[RepositoryItem], Error>
    
    init(result: Result<[RepositoryItem], Error>) {
        self.result = result
    }
    
    func load() async throws -> [RepositoryItem] {
        invokedLoadCount += 1
        return try result.get()
    }
}
