//
//  ChatRoomDBRepository.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/22.
//

import Foundation
import Combine
import FirebaseDatabase

protocol ChatRoomDBRepositoryType {
    func getChatRoom(myUserId: String, otherUserId: String) -> AnyPublisher<ChatRoomObject?, DBError>
    func addChatRoom(_ object: ChatRoomObject, myUserId: String) -> AnyPublisher<Void, DBError>
    func loadChatRooms(myUserId: String) -> AnyPublisher<[ChatRoomObject], DBError>
}

class ChatRoomDBRepository: ChatRoomDBRepositoryType {
    var db: DatabaseReference = Database.database().reference()
    
    func getChatRoom(myUserId: String, otherUserId: String) -> AnyPublisher<ChatRoomObject?, DBError> {
        Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.ChatRooms).child(myUserId).child(otherUserId).getData { error, snapshot in
                if let error {
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull {
                    promise(.success(nil))
                } else {
                    promise(.success(snapshot?.value))
                }
            }
        }
        /// Dictionary를 ChatRoomObject로 변환
        .flatMap { value in
            if let value {
                return Just(value)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: ChatRoomObject?.self, decoder: JSONDecoder())
                    .mapError { DBError.error($0) }
                    .eraseToAnyPublisher()
            } else {
                return Just(nil).setFailureType(to: DBError.self).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addChatRoom(_ object: ChatRoomObject, myUserId: String) -> AnyPublisher<Void, DBError> {
        Just(object)
            .compactMap { try? JSONEncoder().encode($0) }
            .compactMap { try? JSONSerialization.jsonObject(with: $0, options: .fragmentsAllowed) }
            .flatMap { dictionaryValue in
                Future<Void, Error> { [weak self] promise in
                    self?.db.child(DBKey.ChatRooms).child(myUserId).child(object.otherUserId).setValue(dictionaryValue) { error, _ in
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
    
    func loadChatRooms(myUserId: String) -> AnyPublisher<[ChatRoomObject], DBError> {
        Future<Any?, DBError> { [weak self] promise in
            self?.db.child(DBKey.ChatRooms).child(myUserId).getData { error, snapshot in
                if let error {
                    promise(.failure(DBError.error(error)))
                } else if snapshot?.value is NSNull {
                    promise(.success(nil))
                } else {
                    promise(.success(snapshot?.value))
                }
            }
        }
        .flatMap { dictionaryValue in
            if let dict = dictionaryValue as? [String: [String: Any]] {
                return Just(dict)
                    .tryMap { try JSONSerialization.data(withJSONObject: $0) }
                    .decode(type: [String: ChatRoomObject].self, decoder: JSONDecoder())
                    .map { $0.values.map { $0 as ChatRoomObject } }
                    .mapError { DBError.error($0) }
                    .eraseToAnyPublisher()
            } else if dictionaryValue == nil {
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
}
