//
//  AuthenticationService.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/13.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

enum AuthenticationError: Error {
    case clientIDError
    case tokenError
    case invalidated
    case windowError
}

protocol AuthenticationServiceType {
    func checkAuthenticationState() -> String?
    func signInWithGoogle() -> AnyPublisher<User, ServiceError>
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, nonce: String) -> AnyPublisher<User, ServiceError>
    func logout() -> AnyPublisher<Void, ServiceError>
}

class AuthenticationService: AuthenticationServiceType {
    func checkAuthenticationState() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid
        } else {
            return nil
        }
    }
    
    func signInWithGoogle() -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in
            self?.signInWithGoogle { result in
                switch result {
                case let .success(user):
                    promise(.success(user))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        return nonce
    }
    
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, nonce: String) -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in
            self?.handleSignInWithAppleCompletion(authorization, nonce: nonce) { result in
                switch result {
                case let .success(user):
                    promise(.success(user))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, ServiceError> {
        Future { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(.error(error)))
            }
        }.eraseToAnyPublisher()
    }
}

extension AuthenticationService {
    private func signInWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID: String = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthenticationError.clientIDError))
            return
        }
        
        let config: GIDConfiguration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene: UIWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window: UIWindow = windowScene.windows.first,
              let rootViewController: UIViewController = window.rootViewController else {
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let user: GIDGoogleUser = result?.user,
                  let idToken: String = user.idToken?.tokenString else {
                completion(.failure(AuthenticationError.tokenError))
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            self?.authenticateUserWithFirebase(credential: credential, completion: completion)
        }
    }
    
    private func signInWithGoogle() async -> Result<User, Error> {
        guard let clientID: String = FirebaseApp.app()?.options.clientID else {
            return .failure(AuthenticationError.clientIDError)
        }
        
        let config: GIDConfiguration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene: UIWindowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window: UIWindow = await windowScene.windows.first,
              let rootViewController: UIViewController = await window.rootViewController else {
            return .failure(AuthenticationError.windowError)
        }
        
        do {
            let result: GIDSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken: String = result.user.idToken?.tokenString else {
                return .failure(AuthenticationError.tokenError)
            }
            let accessToken: String = result.user.accessToken.tokenString
            let credential: AuthCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            return await authenticateUserWithFirebase(credential: credential)
        } catch {
            return .failure(error)
        }
    }
    
    private func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, 
                                                 nonce: String,
                                                 completion: @escaping (Result<User, Error>) -> Void) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken else {
            completion(.failure(AuthenticationError.tokenError))
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(AuthenticationError.tokenError))
            return
        }
        
        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                       rawNonce: nonce,
                                                       fullName: appleIDCredential.fullName)
        authenticateUserWithFirebase(credential: credential) { result in
            switch result {
            case var .success(user):
                user.name = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                completion(.success(user))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func authenticateUserWithFirebase(credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let result else {
                completion(.failure(AuthenticationError.invalidated))
                return
            }
            
            let firebaseUser: FirebaseAuth.User = result.user
            let user: User = .init(
                id: firebaseUser.uid,
                name: firebaseUser.displayName ?? "",
                phoneNumber: firebaseUser.phoneNumber,
                profileURL: firebaseUser.photoURL?.absoluteString
            )
            completion(.success(user))
        }
    }
    
    private func authenticateUserWithFirebase(credential: AuthCredential) async -> Result<User, Error> {
        do {
            let result: AuthDataResult = try await Auth.auth().signIn(with: credential)
            let firebaseUser: FirebaseAuth.User = result.user
            let user: User = .init(
                id: firebaseUser.uid,
                name: firebaseUser.displayName ?? "",
                phoneNumber: firebaseUser.phoneNumber,
                profileURL: firebaseUser.photoURL?.absoluteString
            )
            return .success(user)
        } catch {
            return .failure(error)
        }
    }
    
}

class StubAuthenticationService: AuthenticationServiceType {
    func checkAuthenticationState() -> String? {
        return nil
    }
    
    func signInWithGoogle() -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        return ""
    }
    
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, nonce: String) -> AnyPublisher<User, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
