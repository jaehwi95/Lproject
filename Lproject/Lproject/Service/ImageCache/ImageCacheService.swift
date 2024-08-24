//
//  ImageCacheService.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/20.
//

import UIKit
import Combine

protocol ImageCacheServiceType {
    func image(for key: String) -> AnyPublisher<UIImage?, Never>
}

class ImageCacheService: ImageCacheServiceType {
    let memoryStorage: MemoryStorageType
    let diskStorage: DiskStorageType
    
    init(memoryStorage: MemoryStorageType, diskStorage: DiskStorageType) {
        self.memoryStorage = memoryStorage
        self.diskStorage = diskStorage
    }
    
    func image(for key: String) -> AnyPublisher<UIImage?, Never> {
        /*
            1. memory storage 확인
            2. disk storage 확인
            3. url session 으로 가져와 각각 넣어줌
         */
        imageWithMemoryCache(for: key)
            .flatMap { image -> AnyPublisher<UIImage?, Never> in
                if let image {
                    return Just(image).eraseToAnyPublisher()
                } else {
                    // disk storage 확인
                    return self.imageWithDiskCache(for: key)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func imageWithMemoryCache(for key: String) -> AnyPublisher<UIImage?, Never> {
        Future { [weak self] promise in
            let image = self?.memoryStorage.value(for: key)
            promise(.success(image))
        }.eraseToAnyPublisher()
    }
    
    func imageWithDiskCache(for key: String) -> AnyPublisher<UIImage?, Never> {
        Future<UIImage?, Never> { [weak self] promise in
            do {
                let image = try self?.diskStorage.value(for: key)
                promise(.success(image))
            } catch {
                promise(.success(nil))
            }
        }
        .flatMap { image -> AnyPublisher<UIImage?, Never> in
            if let image {
                return Just(image)
                    .handleEvents(receiveOutput: { [weak self] image in
                        guard let image else { return }
                        self?.store(for: key, image: image, toDisk: false)
                    })
                    .eraseToAnyPublisher()
            } else {
                // Network 통신
                return self.remoteImage(for: key)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func remoteImage(for urlString: String) -> AnyPublisher<UIImage?, Never> {
        URLSession.shared.dataTaskPublisher(for: URL(string: urlString)!)
            .map { data, _ in
                UIImage(data: data)
            }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] image in
                guard let image else { return }
                self?.store(for: urlString, image: image, toDisk: true)
            })
            .eraseToAnyPublisher()
    }
    
    func store(for key: String, image: UIImage, toDisk: Bool) {
        memoryStorage.store(for: key, image: image)
        if toDisk {
            try? diskStorage.store(for: key, image: image)
        }
    }
}

class StubImageCacheService: ImageCacheServiceType {
    func image(for key: String) -> AnyPublisher<UIImage?, Never> {
        Empty().eraseToAnyPublisher()
    }
}
