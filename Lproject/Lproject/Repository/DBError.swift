//
//  DBError.swift
//  Lproject
//
//  Created by Jaehwi Kim on 8/18/24.
//

import Foundation

enum DBError: Error {
    case error(Error)
    case emptyValue
    case invalidatedType
}
