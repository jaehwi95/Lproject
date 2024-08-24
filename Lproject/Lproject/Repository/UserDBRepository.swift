//
//  UserDBRepository.swift
//  Lproject
//
//  Created by Jaehwi Kim on 8/18/24.
//

import Foundation
import Combine
import FirebaseDatabase

protocol UserDBRepositoryType {
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError>
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError>
    func getUser(userId: String) async throws -> UserObject
    func updateUser(userId: String, key: String, value: Any) async throws
    func loadUsers() -> AnyPublisher<[UserObject], DBError>
    func addUserAfterContact(users: [UserObject]) -> AnyPublisher<Void, DBError>
}

class UserDBRepository: UserDBRepositoryType {
    var db: DatabaseReference = Database.database().reference()
    
    func addUser(_ object: UserObject) -> AnyPublisher<Void, DBError> {
        /// object를 data 타입으로 변환, 다음 dict로 변환
        Just(object)
            /// Data 타입으로 변환
            .compactMap { try? JSONEncoder().encode($0) }
            /// Dict 타입으로 변환
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) }
            .flatMap { value in
                /// Future - 최종적으로 하나의 값을 생성, 후 Success / Fail 해줌
                /// Asynchronous 작업을 수행해야함 -> 해당 작업은 Future<Void, Error> 를 리턴함
                /// 리턴된 퍼블리셔를 Publisher<Void, DBError>로 변환하기 위해서 flatMap으로 작업
                /// 안하면 Publisher<Publisher<Void, DBError>> 로 됨
                Future<Void, Error> { [weak self] promise in // users/userId/..
                    self?.db.child(DBKey.Users).child(object.id).setValue(value) { error, _ in
                        if let error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
            .mapError { DBError.error($0) }
            .eraseToAnyPublisher()
    }
    
    
    func getUser(userId: String) -> AnyPublisher<UserObject, DBError> {
        Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.Users).child(userId).getData { error, snapshot in
                if let error {
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull {
                    // value not exist
                    promise(.success(nil))
                } else {
                    promise(.success(snapshot?.value))
                }
            }
        }
        .flatMap { value in
            if let value {
                return Just(value)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: UserObject.self, decoder: JSONDecoder())
                    .mapError { DBError.error($0) }
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: .emptyValue).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) async throws -> UserObject {
        guard let value = try await self.db.child(DBKey.Users).child(userId).getData().value else {
            throw DBError.emptyValue
        }
        
        let data = try JSONSerialization.data(withJSONObject: value)
        let userObject = try JSONDecoder().decode(UserObject.self, from: data)
        return userObject
    }
    
    func updateUser(userId: String, key: String, value: Any) async throws {
        try await self.db.child(DBKey.Users).child(userId).child(key).setValue(value)
    }
    
    func loadUsers() -> AnyPublisher<[UserObject], DBError> {
        Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.Users).getData { error, snapshot in
                if let error {
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull {
                    promise(.success(nil))
                } else {
                    promise(.success(snapshot?.value))
                }
            }
        }
        .flatMap { value in
            if let dict = value as? [String: [String: Any]] {
                return Just(dict)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: [String: UserObject].self, decoder: JSONDecoder())
                    .map { $0.values.map { $0 as UserObject } }
                    .mapError { DBError.error($0) }
                    .eraseToAnyPublisher()
            } else if value == nil {
                return Just([])
                    .setFailureType(to: DBError.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: .invalidatedType)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addUserAfterContact(users: [UserObject]) -> AnyPublisher<Void, DBError> {
        /// Zip 사용 없이 내가 알아볼 수 있는 형식으로 변환
        users.publisher
            .compactMap { userObject in
                guard let dataConverted = try? JSONEncoder().encode(userObject) else {
                    return nil
                }
                guard let dictionaryConverted = try? JSONSerialization.jsonObject(with: dataConverted, options: .fragmentsAllowed) as? [String:Any] else {
                    return nil
                }
                let userId: String = userObject.id
                return (userId, dictionaryConverted)
            }
            .flatMap { (userId: String, dictionaryConverted: [String: Any]) in
                Future<Void, Error> { [weak self] promise in
                    self?.db.child(DBKey.Users).child(userId).setValue(dictionaryConverted) { error, _ in
                        if let error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
            .mapError { .error($0) }
            .eraseToAnyPublisher()

        /*
        /// ???
        /// 2개의 Publisher들을 튜플로 합침
        Publishers.Zip(users.publisher, users.publisher)
            /// 두번째 Published 값 encoding작업
            /// 성공시 (UserObject, Data) 튜플
            .compactMap { origin, converted in
                if let converted = try? JSONEncoder().encode(converted) {
                    return (origin, converted)
                } else {
                    return nil
                }
            }
            /// 두번째 Published 값 Dictionary로 변환 작업
            /// 성공시 (UserObject, Dictionary) 튜플
            .compactMap { origin, converted in
                if let converted = try? JSONSerialization.jsonObject(with: converted, options: .fragmentsAllowed) {
                    return (origin, converted)
                } else {
                    return nil
                }
            }
            .flatMap { origin, converted in
                Future<Void, Error> { [weak self] promise in
                    self?.db.child(DBKey.Users).child(origin.id).setValue(converted) { error, _ in
                        if let error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
                }
            }
            .last()
            .mapError { .error($0) }
            .eraseToAnyPublisher()
         
         */
    }
}
