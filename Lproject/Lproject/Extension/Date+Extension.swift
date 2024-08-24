//
//  Date+Extension.swift
//  Lproject
//
//  Created by Jaehwi Kim on 2024/08/23.
//

import Foundation

extension Date {
    var toChatDateKey: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd E"
        return formatter.string(from: self)
    }
}
