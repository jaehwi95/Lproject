//
//  HomeModalDestination.swift
//  Lproject
//
//  Created by Jaehwi Kim on 8/18/24.
//

import Foundation

enum HomeModalDestination: Hashable, Identifiable {
    case myProfile
    case otherProfile(String)
    
    var id: Int {
        hashValue
    }
}
