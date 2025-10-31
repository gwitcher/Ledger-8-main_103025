//
//  ViewExtensions.swift
//  Ledger 8
//
//  Created by Gabe Witcher on 10/30/25.
//

import SwiftUI
import UIKit

extension View {
    /// Hide the keyboard by resigning first responder
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}