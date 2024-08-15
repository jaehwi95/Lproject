//
//  DIContainer.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/13.
//

import Foundation

class DIContainer: ObservableObject {
    var services: ServiceType
    
    init(services: ServiceType) {
        self.services = services
    }
}
