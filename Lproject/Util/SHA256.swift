//
//  SHA256.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/14.
//

import Foundation
import CryptoKit

@available(iOS 13, *)
func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    
    return hashString
}
