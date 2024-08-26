//
//  ChatItemView.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/26.
//

import SwiftUI

struct ChatItemView: View {
    let message: String
    let direction: ChatItemDirection
    let date: Date
    
    var body: some View {
        HStack {
            if direction == .right {
                Spacer()
            }
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.blackFix)
                .padding(.vertical, 9)
                .padding(.horizontal, 20)
                .background(direction.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .overlay(alignment: direction.overlayAlignment) {
                    direction.overlayImage
                }
            if direction == .left {
                Spacer()
            }
        }
        .padding(.horizontal, 35)
    }
    
    var dateView: some View {
        EmptyView()
    }
}

#Preview {
    ChatItemView(message: "안녕하세요", direction: .right, date: Date())
}
