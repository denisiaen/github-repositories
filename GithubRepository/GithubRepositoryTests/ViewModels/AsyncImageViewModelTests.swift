//
//  AsyncImageViewModel.swift
//  GithubRepositoryTests
//
//  Created by Denisia Enasescu on 06.07.2023.
//

import XCTest
import GithubRepository

final class AsyncImageViewModelTests: XCTestCase {

    func test_init_deliversEmptyData() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.invokedLoadCount, 0)
        XCTAssertNil(sut.data)
        XCTAssertNil(sut.error)
    }
    
    func test_load_invokesLoadImageData() async {
        let (sut, loader) = makeSUT()
        
        await sut.load(url: anyURL())
        
        XCTAssertEqual(loader.invokedLoadCount, 1)
    }
    
    func test_load_deliversErrorOnImageDataLoaderError() async {
        let (sut, _) = makeSUT(imageLoaderResult: .failure(anyNSError()))
        
        await sut.load(url: anyURL())

        XCTAssertNotNil(sut.error)
    }
    
    func test_load_deliversDataOnImageDataLoaderSuccess() async {
        let (sut, _) = makeSUT(imageLoaderResult: .success(anyData()))
        
        await sut.load(url: anyURL())
        
        XCTAssertNotNil(sut.data)
    }

    // MARK: - Helpers
    
    private func makeSUT(imageLoaderResult: Result<Data,Error> = .success(anyData()), file: StaticString = #filePath, line: UInt = #line) -> (viewModel: AsyncImageViewModel, loader: ImageDataLoaderStub) {
        let loaderStub = ImageDataLoaderStub(result: imageLoaderResult)
        let viewModel = AsyncImageViewModel(imageDataLoader: loaderStub)
        trackForMemoryLeaks(loaderStub)
        trackForMemoryLeaks(viewModel)
        return (viewModel, loaderStub)
    }
    
    class ImageDataLoaderStub: ImageDataLoader {
        var invokedLoadCount = 0
        
        private var result: Result<Data, Error>
        
        init(result: Result<Data, Error>) {
            self.result = result
        }
        
        func load(url: URL) async throws -> Data {
            invokedLoadCount += 1
            return try result.get()
        }
    }
}
