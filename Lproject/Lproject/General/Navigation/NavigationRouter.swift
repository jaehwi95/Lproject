//
//  NavigationRouter.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/23.
//

import Foundation

class NavigationRouter: ObservableObject {
    @Published var destinations: [NavigationDestination] = []
    
    func push(to view: NavigationDestination) {
        destinations.append(view)
    }
    
    func pop() {
        _ = destinations.popLast()
    }
    
    func popToRootView() {
        destinations = []
    }
}
