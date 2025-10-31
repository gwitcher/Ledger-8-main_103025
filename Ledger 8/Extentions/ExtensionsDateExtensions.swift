//
//  DateExtensions.swift
//  Ledger 8
//
//  Created by Gabe Witcher on 10/30/25.
//

import Foundation

extension Date {
    /// Add minutes to the current date
    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }

    /// Add hours to the current date
    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }
}