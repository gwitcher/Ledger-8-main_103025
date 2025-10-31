//
//  ValidationSummaryBanner.swift
//  Ledger 8
//
//  Created for reusable validation banner component
//

import SwiftUI

/// A reusable validation banner that shows formatting errors across different forms
struct ValidationSummaryBanner: View {
    let title: String
    let validationErrors: [ValidationBannerError]
    @Binding var isVisible: Bool
    
    var body: some View {
        if isVisible && !validationErrors.isEmpty {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Button {
                            withAnimation(.easeOut(duration: 0.3)) {
                                isVisible = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(validationErrors, id: \.id) { error in
                            HStack {
                                Image(systemName: error.icon)
                                    .frame(width: 16)
                                    .foregroundColor(.secondary)
                                Text("\(error.fieldName): \(error.message)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }
}

/// Represents a single validation error for display in the banner
struct ValidationBannerError {
    let id = UUID()
    let fieldName: String
    let message: String
    let icon: String
    
    init(fieldName: String, message: String, icon: String) {
        self.fieldName = fieldName
        self.message = message
        self.icon = icon
    }
}

/// Convenience initializers for common field types
extension ValidationBannerError {
    static func email(_ message: String) -> ValidationBannerError {
        ValidationBannerError(fieldName: "Email", message: message, icon: "envelope")
    }
    
    static func phone(_ message: String) -> ValidationBannerError {
        ValidationBannerError(fieldName: "Phone", message: message, icon: "phone")
    }
    
    static func routingNumber(_ message: String) -> ValidationBannerError {
        ValidationBannerError(fieldName: "Routing Number", message: message, icon: "number.circle")
    }
    
    static func accountNumber(_ message: String) -> ValidationBannerError {
        ValidationBannerError(fieldName: "Account Number", message: message, icon: "number.circle")
    }
    
    static func venmo(_ message: String) -> ValidationBannerError {
        ValidationBannerError(fieldName: "Venmo", message: message, icon: "at.circle")
    }
    
    static func zelle(_ message: String) -> ValidationBannerError {
        ValidationBannerError(fieldName: "Zelle", message: message, icon: "dollarsign.circle")
    }
    
    static func projectName(_ message: String) -> ValidationBannerError {
        ValidationBannerError(fieldName: "Project Name", message: message, icon: "folder")
    }
    
    static func client(_ message: String) -> ValidationBannerError {
        ValidationBannerError(fieldName: "Client", message: message, icon: "person")
    }
    
    static func dateRange(_ message: String) -> ValidationBannerError {
        ValidationBannerError(fieldName: "Date Range", message: message, icon: "calendar")
    }
    
    static func artist(_ message: String) -> ValidationBannerError {
        ValidationBannerError(fieldName: "Artist", message: message, icon: "music.note")
    }
}

#Preview {
    NavigationView {
        Form {
            ValidationSummaryBanner(
                title: "Please check field formatting:",
                validationErrors: [
                    .email("Invalid email format"),
                    .phone("Invalid phone number format"),
                    .routingNumber("Must be exactly 9 digits")
                ],
                isVisible: .constant(true)
            )
            
            Section("Sample Form") {
                Text("Sample content")
            }
        }
    }
}