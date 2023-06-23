//
//  RepositoriesViewModelTests.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 23.06.2023.
//

import XCTest
import GithubRepository
import Combine

final class RepositoriesViewModelTests: XCTestCase {
    private var cancellable = Set<AnyCancellable>()

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
    
    func test_viewDidAppear_deliversResultOnRepositoriesLoadSuccess() async {
        let item1 = RepositoryItem(id: 1, userName: "A name", imageURL: URL(string: "http://url")!, repositoryName: "A repo", description: nil, language: nil, stars: nil)
        let item2 = RepositoryItem(id: 2, userName: "Another name", imageURL: URL(string: "http://another-url")!, repositoryName: "Another repo", description: "A description", language: "A language", stars: 2)
        
        let (sut, _) = makeSUT(repositoriesLoaderResult: .success([item1, item2]))
        
        await sut.viewDidAppear()
        
        XCTAssertEqual(sut.repositoryItems, [item1, item2])
    }
    
    func test_viewDidAppear_startsAndStopsLoadingOnRepositoriesLoadError() async {
        let (sut, _) = makeSUT(repositoriesLoaderResult: .failure(anyNSError()))
        
        let exp = expectation(description: "Wait for collecting isLoading values")
        sut.$isLoading.dropFirst().collect(2).sink { values in
            XCTAssertEqual(values, [true, false])
            exp.fulfill()
        }.store(in: &cancellable)
        
        await sut.viewDidAppear()

        await fulfillment(of: [exp], timeout: 1.0)
    }
    
    func test_viewDidAppear_startsAndStopsLoadingOnRepositoriesLoadSuccess() async {
        let (sut, _) = makeSUT(repositoriesLoaderResult: .success([anyRepositoryItem()]))
        
        let exp = expectation(description: "Wait for collecting isLoading values")
        sut.$isLoading.dropFirst().collect(2).sink { values in
            XCTAssertEqual(values, [true, false])
            exp.fulfill()
        }.store(in: &cancellable)
        
        await sut.viewDidAppear()

        await fulfillment(of: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        repositoriesLoaderResult: Result<[RepositoryItem], Error> = .success([anyRepositoryItem()]), file: StaticString = #filePath, line: UInt = #line) -> (viewModel: RepositoriesViewModel, loader: RepositoriesLoaderStub
        ) {
        let repositoriesLoaderStub = RepositoriesLoaderStub(result: repositoriesLoaderResult)
        let sut = RepositoriesViewModel(repositoriesLoader: repositoriesLoaderStub)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(repositoriesLoaderStub, file: file, line: line)
        return (sut, repositoriesLoaderStub)
    }
}

private func anyRepositoryItem() -> RepositoryItem {
    RepositoryItem(id: 1, userName: "A name", imageURL: URL(string: "http://url")!, repositoryName: "A repo", description: nil, language: nil, stars: nil)
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
