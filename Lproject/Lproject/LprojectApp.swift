//
//  LprojectApp.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/13.
//

import SwiftUI

// App 시작점
@main
struct LprojectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    // Dependency Injection
    @StateObject var container: DIContainer = .init(services: Services())
    
    var body: some Scene {
        WindowGroup {
            AuthenticatedView(
                authViewModel: .init(container: container),
                navigationRouter: .init()
            )
                .environmentObject(container)
                // Device에 따라 SafeArea가 다름 (ex. iPhone 8), BottomSafeArea를 확인하여 알맞는 padding 추가
                .safeAreaBottomPadding()
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .background:
                break
            case .inactive:
                break
            case .active:
                break
            default:
                break
            }
        }
    }
}
