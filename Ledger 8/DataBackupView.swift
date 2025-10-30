//
//  DataBackupView.swift
//  Ledger 8
//
//  Backup interface for model migration
//

import SwiftUI
import SwiftData

struct DataBackupView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage("userData") var userData = UserData()
    
    @State private var isExporting = false
    @State private var shareSheet: ShareSheet?
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create Backup")
                            .font(.headline)
                        Text("Export your current data before making model changes. This creates a safety net in case you need to reference your old projects.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Export Options") {
                    Button {
                        exportJSON()
                    } label: {
                        Label("Export as JSON", systemImage: "doc.text")
                    }
                    .disabled(isExporting)
                    
                    Button {
                        exportCSV()
                    } label: {
                        Label("Export as CSV", systemImage: "tablecells")
                    }
                    .disabled(isExporting)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("What gets backed up:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("• All projects with items and fees")
                            Text("• All client information")
                            Text("• Your company and banking settings")
                            Text("• Invoice numbers and references")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                
                if isExporting {
                    Section {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Creating backup...")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Data Backup")
            .alert("Backup Status", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .sheet(item: $shareSheet) { sheet in
                sheet
            }
        }
    }
    
    private func exportJSON() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let backup = DataBackupService.createFullBackup(
                modelContext: modelContext,
                userData: userData
            ) else {
                DispatchQueue.main.async {
                    isExporting = false
                    alertMessage = "Failed to create backup. Please try again."
                    showAlert = true
                }
                return
            }
            
            guard let jsonURL = DataBackupService.exportToJSON(backup) else {
                DispatchQueue.main.async {
                    isExporting = false
                    alertMessage = "Failed to export JSON file."
                    showAlert = true
                }
                return
            }
            
            DispatchQueue.main.async {
                isExporting = false
                shareSheet = ShareSheet(items: [jsonURL])
            }
        }
    }
    
    private func exportCSV() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let backup = DataBackupService.createFullBackup(
                modelContext: modelContext,
                userData: userData
            ) else {
                DispatchQueue.main.async {
                    isExporting = false
                    alertMessage = "Failed to create backup. Please try again."
                    showAlert = true
                }
                return
            }
            
            let csvURLs = DataBackupService.exportToCSV(backup)
            
            DispatchQueue.main.async {
                isExporting = false
                if csvURLs.isEmpty {
                    alertMessage = "Failed to export CSV files."
                    showAlert = true
                } else {
                    shareSheet = ShareSheet(items: csvURLs)
                }
            }
        }
    }
}

// Helper for ShareSheet
extension ShareSheet: Identifiable {
    var id: String {
        return "shareSheet"
    }
}

#Preview {
    DataBackupView()
}