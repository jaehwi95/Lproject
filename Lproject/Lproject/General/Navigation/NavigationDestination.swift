//
//  NavigationDestination.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/23.
//

import Foundation

enum NavigationDestination: Hashable {
    case chat(chatRoomId: String, myUserId: String, otherUserId: String)
    case search
}
