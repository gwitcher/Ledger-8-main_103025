//
//  ValidationBulletPoint.swift
//  Ledger 8
//
//  Created for consistent bullet point styling in validation displays
//

import SwiftUI

/// A small, consistent bullet point for validation error displays
struct ValidationBulletPoint: View {
    var body: some View {
        Image(systemName: "circle.fill")
            .font(.system(size: 6))
            .foregroundColor(.secondary)
            .frame(width: 16, alignment: .center)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 4) {
        HStack {
            ValidationBulletPoint()
            Text("Sample validation error message")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        
        HStack {
            ValidationBulletPoint()
            Text("Another validation error message")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        
        HStack {
            ValidationBulletPoint()
            Text("Third validation error message")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    .padding()
}