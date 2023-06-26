//
//  GithubRepositoryApp.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView:  makeRepositoriesView())
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func makeRepositoriesView() -> RepositoriesView {
        RepositoriesUIComposer.repositoriesComposeWith(repositoriesLoader: apiRepositoriesLoader, imageDataLoader: makeApiImageDataLoader)
    }
    
    var httpClient: HTTPClient {
        let urlSession = URLSessionHTTPClient()
        return urlSession
    }
    
    lazy var apiRepositoriesLoader: RepositoriesLoader = {
        let url = URL(string: "https://api.github.com/search/repositories?q=language=+sort:stars")!
        return APIRepositoriesLoader(client: httpClient, url: url)
    }()
    
    func makeApiImageDataLoader() -> ImageDataLoader {
        APIImageDataLoader(client: httpClient)
    }
}

final class RepositoriesUIComposer {
    private init() {}
    
    static func repositoriesComposeWith(repositoriesLoader: RepositoriesLoader, imageDataLoader: @escaping () -> ImageDataLoader) -> RepositoriesView {
        let viewModel = RepositoriesViewModel(repositoriesLoader: repositoriesLoader)
        return RepositoriesView(viewModel: viewModel, imageDataLoader: imageDataLoader)
    }
}
