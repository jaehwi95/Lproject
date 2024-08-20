//
//  MemoryStorage.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/20.
//

import UIKit

protocol MemoryStorageType {
    func value(for key: String) -> UIImage?
    func store(for key: String, image: UIImage)
}

class MemoryStorage: MemoryStorageType {
    // NS 계열이어서 두 Type다 class type이어야 함
    var cache = NSCache<NSString, UIImage>()
    
    func value(for key: String) -> UIImage? {
        cache.object(forKey: NSString(string: key))
    }
    
    func store(for key: String, image: UIImage) {
        // 실제 작업할때는 cost도 추가
        cache.setObject(image, forKey: NSString(string: key))
    }
}
