//
//  URLImageView.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/22.
//

import SwiftUI

struct URLImageView: View {
    @EnvironmentObject var container: DIContainer
    
    let urlString: String?
    let placeholderImageName: String
    
    init(urlString: String?, placeholderImageName: String? = nil) {
        self.urlString = urlString
        self.placeholderImageName = placeholderImageName ?? "placeholder"
    }
    
    var body: some View {
        if let urlString, !urlString.isEmpty {
            URLInnerImageView(viewModel: .init(container: container, urlString: urlString), placeholderName: placeholderImageName)
                // innver view가 url 이 변경되었을시 내부에 있는 state object도 변경해야 함으로 추가
                .id(urlString)
        } else {
            Image(placeholderImageName)
                .resizable()
        }
    }
}

fileprivate struct URLInnerImageView: View {
    @StateObject var viewModel: URLImageViewModel
    let placeholderName: String
    
    var placeholderImage: UIImage {
        UIImage(named: placeholderName) ?? UIImage()
    }
    
    var body: some View {
        Image(uiImage: viewModel.loadedImage ?? placeholderImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .onAppear {
                if !viewModel.loadingOrSuccess {
                    viewModel.start()
                }
            }
    }
}

#Preview {
    URLImageView(urlString: nil)
}
