//
//  URLImageViewModel.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/22.
//

import UIKit
import Combine

class URLImageViewModel: ObservableObject {
    var loadingOrSuccess: Bool {
        return loading || loadedImage != nil
    }
    
    @Published var loadedImage: UIImage?
    
    private var loading: Bool = false
    private var urlString: String
    private var container: DIContainer
    private var subscription = Set<AnyCancellable>()
    
    init(container: DIContainer, urlString: String) {
        self.container = container
        self.urlString = urlString
    }
    
    func start() {
        guard !urlString.isEmpty else { return }
        loading = true
        // 긴 작업으로 background에서 작업
        container.services.imageCacheService.image(for: urlString)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.loading = false
                self?.loadedImage = image
            }
            .store(in: &subscription)
    }
}
