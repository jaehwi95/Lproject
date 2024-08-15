//
//  View+Extension.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/13.
//

import SwiftUI

struct SafeAreaBottomPadding: ViewModifier {
    func body(content: Content) -> some View {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           window.safeAreaInsets.bottom == 0 {
            content.padding(.bottom)
        } else {
            content
        }
    }
}

extension View {
    func safeAreaBottomPadding() -> some View {
        modifier(SafeAreaBottomPadding())
    }
}
