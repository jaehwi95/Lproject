//
//  MyProfileViewModel.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/19.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
class MyProfileViewModel: ObservableObject {
    @Published var userInfo: User?
    @Published var isPresentedDescriptionEditView: Bool = false
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            Task {
                await updateProfileImage(pickerItem: imageSelection)
            }
        }
    }
    
    
    private let userId: String
    private var container: DIContainer
    
    init(container: DIContainer, userId: String) {
        self.container = container
        self.userId = userId
    }
    
    func getUser() async {
        if let user = try? await container.services.userService.getUser(userId: userId) {
            userInfo = user
        }
    }
    
    func updateDescription(_ description: String) async {
        do {
            try await container.services.userService.updateDescription(userId: userId, description: description)
            userInfo?.description = description
        } catch {
            
        }
    }
    
    func updateProfileImage(pickerItem: PhotosPickerItem?) async {
        guard let pickerItem else { return }
        
        do {
            // PickerService를 통한 data 가져오기
            let data: Data = try await container.services.photoPickerService.loadTransferable(from: pickerItem)
            // FirebaseStorage에 업로드 및 url 가져오기
            let url: URL = try await container.services.uploadService.uploadImage(source: .profile(userId: userId), data: data)
            try await container.services.userService.updateProfileURL(userId: userId, urlString: url.absoluteString)
            userInfo?.profileURL = url.absoluteString
        } catch {
            print(error.localizedDescription)
        }
    }
}
