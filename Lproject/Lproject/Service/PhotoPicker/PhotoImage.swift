//
//  PhotoImage.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/20.
//

import Foundation
import SwiftUI
import PhotosUI

struct PhotoImage: Transferable {
    let data: Data
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw PhotoPickerError.importFailed
            }
            
            guard let data = uiImage.jpegData(compressionQuality: 0.3) else  {
                throw PhotoPickerError.importFailed
            }
            
            return PhotoImage(data: data)
        }
    }
}
