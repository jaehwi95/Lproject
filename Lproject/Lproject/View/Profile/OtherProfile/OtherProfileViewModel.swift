//
//  OtherProfileViewModel.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/22.
//

import Foundation

@MainActor
class OtherProfileViewModel: ObservableObject {
    @Published var userInfo: User?
    
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
}
