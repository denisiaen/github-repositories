//
//  AsyncImageView.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import SwiftUI

struct AsyncImageView<Placeholder: View>: View {
    private let placeholder: Placeholder

    init(url: URL, placeholder: Placeholder) {
        self.placeholder = placeholder
    }

    var body: some View {
       Image(systemName: "pencil")
            .foregroundColor(.black)
    }
}

struct AsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncImageView(url: URL(string: "https://avatars.githubusercontent.com/u/4314092?v=4")!, placeholder: Color.red)
    }
}
