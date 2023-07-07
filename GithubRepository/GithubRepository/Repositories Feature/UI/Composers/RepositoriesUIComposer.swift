//
//  RepositoriesUIComposer.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 07.07.2023.
//

import Foundation
import UIKit
import SwiftUI

final class RepositoriesUIComposer {
    private init() {}
    
    static func repositoriesComposeWith(repositoriesLoader: RepositoriesLoader, imageDataLoader: @escaping () -> ImageDataLoader) -> RepositoriesView {
        let viewModel = RepositoriesViewModel(repositoriesLoader: repositoriesLoader)
        let view = RepositoriesView(viewModel: viewModel) { item in
            RepositoryRow(
                item: item,
                asyncImageViewModel: { makeAsyncImageViewModel(imageDataLoader: imageDataLoader) },
                isLoading: isLoadingBinded(viewModel: viewModel))
        }
        
        return view
    }
    
    private static func makeAsyncImageViewModel(imageDataLoader: () -> ImageDataLoader) -> AsyncImageViewModel<UIImage> {
        AsyncImageViewModel(imageDataLoader: imageDataLoader(), imageTransformer: UIImage.init)
    }
    
    private static func isLoadingBinded(viewModel: RepositoriesViewModel) -> Binding<Bool> {
        Binding<Bool>(get: { viewModel.isRefreshing }, set: { viewModel.isRefreshing = $0 })
    }
}
