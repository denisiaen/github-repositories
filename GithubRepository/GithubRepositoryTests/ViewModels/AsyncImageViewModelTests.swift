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
        XCTAssertNil(sut.image)
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
    
    func test_load_rendersImageLoadedFromURL() async {
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        let (sut, _) = makeSUT(imageLoaderResult: .success(imageData0))

        await sut.load(url: anyURL())
        
        XCTAssertNotNil(sut.image)
        XCTAssertEqual(sut.renderedImage, imageData0, "Expected image once image loading completes successfully")
    }

    // MARK: - Helpers
    
    private func makeSUT(imageLoaderResult: Result<Data,Error> = .success(anyData()), file: StaticString = #filePath, line: UInt = #line) -> (viewModel: AsyncImageViewModel<UIImage>, loader: ImageDataLoaderStub) {
        let loaderStub = ImageDataLoaderStub(result: imageLoaderResult)
        let viewModel = AsyncImageViewModel(imageDataLoader: loaderStub, imageTransformer: UIImage.init)
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

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}

private extension AsyncImageViewModel<UIImage> {
    var renderedImage: Data? {
        image?.pngData()
    }
}
