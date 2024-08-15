//
//  LoginView.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/13.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("로그인")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.bkText)
                    .padding(.top, 80)
                
                Text("아래 제공되는 서비스로 로그인을 해주세요.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.greyDeep)
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Button(
                action: {
                    authViewModel.send(action: .googleLogin)
                },
                label: {
                    Text("Google로 로그인")
                }
            )
            .buttonStyle(LoginButtonStyle(textColor: .bkText, borderColor: .greyLight))
            SignInWithAppleButton { request in
                authViewModel.send(action: .appleLogin(request))
            } onCompletion: { result in
                authViewModel.send(action: .appleLoginCompletion(result))
            }
            .frame(height: 40)
            .padding(.horizontal, 15)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(
                    action: {
                        dismiss()
                    },
                    label: {
                        Image("back")
                    }
                )
            }
        }
        .overlay {
            if authViewModel.isLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    LoginView()
}
