//
//  MyProfileDescriptionEditView.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/19.
//

import SwiftUI

struct MyProfileDescriptionEditView: View {
    @Environment(\.dismiss) var dismiss
    @State var description: String
    
    var onCompleted: (String) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("상태메시지를 입력해주세요", text: $description)
                    .multilineTextAlignment(.center)
            }
            .toolbar {
                Button(
                    action: {
                        dismiss()
                        onCompleted(description)
                    },
                    label: {
                        Text("완료")
                    }
                )
                .disabled(description.isEmpty)
            }
        }
    }
}

#Preview {
    MyProfileDescriptionEditView(description: "") { _ in
        
    }
}
