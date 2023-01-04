//
//  Date+Extendsions.swift
//  ios_chime
//
//  Created by TMLIJKTMAC08 on 28/11/22.
//

import Foundation


extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
