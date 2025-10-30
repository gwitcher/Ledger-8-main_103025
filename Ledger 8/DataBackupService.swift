//
//  DataBackupService.swift
//  Ledger 8
//
//  Created for model migration backup
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Backup Data Structures (Simple, flat structures)
struct ProjectBackup: Codable {
    let id: String
    let projectName: String?
    let artist: String?
    let startDate: Date
    let endDate: Date
    let mediaType: String
    let status: String
    let notes: String?
    let delivered: Bool
    let paid: Bool
    let dateOpened: Date
    let dateDelivered: Date
    let dateClosed: Date
    
    // Client info (flattened)
    let clientName: String
    let clientEmail: String
    let clientPhone: String
    let clientCompany: String
    
    // Items (as array of dictionaries for CSV compatibility)
    let items: [ItemBackup]
    
    // Invoice info
    let invoiceNumber: Int?
    let invoiceName: String?
}

struct ItemBackup: Codable {
    let name: String?
    let fee: Double
    let itemType: String
    let notes: String?
}

struct ClientBackup: Codable {
    let id: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let phone: String?
    let company: String?
    let address: String?
    let city: String?
    let state: String?
    let zip: String?
    let notes: String?
}

struct FullBackup: Codable {
    let backupDate: Date
    let appVersion: String
    let projects: [ProjectBackup]
    let clients: [ClientBackup]
    let userData: UserData
}

// MARK: - Backup Service
class DataBackupService {
    
    static func createFullBackup(modelContext: ModelContext, userData: UserData) -> FullBackup? {
        do {
            // Fetch all projects
            let projectDescriptor = FetchDescriptor<Project>()
            let projects = try modelContext.fetch(projectDescriptor)
            
            // Fetch all clients  
            let clientDescriptor = FetchDescriptor<Client>()
            let clients = try modelContext.fetch(clientDescriptor)
            
            // Convert to backup structures
            let projectBackups = projects.compactMap { createProjectBackup(from: $0) }
            let clientBackups = clients.map { createClientBackup(from: $0) }
            
            return FullBackup(
                backupDate: Date(),
                appVersion: "1.0-pre-migration",
                projects: projectBackups,
                clients: clientBackups,
                userData: userData
            )
        } catch {
            print("Backup creation failed: \(error)")
            return nil
        }
    }
    
    private static func createProjectBackup(from project: Project) -> ProjectBackup? {
        // Convert items
        let itemBackups = (project.items ?? []).map { item in
            ItemBackup(
                name: item.name,
                fee: item.fee,
                itemType: item.itemType.rawValue,
                notes: item.notes
            )
        }
        
        return ProjectBackup(
            id: String(describing: project.id),
            projectName: project.projectName,
            artist: project.artist,
            startDate: project.startDate,
            endDate: project.endDate,
            mediaType: project.mediaType.rawValue,
            status: project.status.rawValue,
            notes: project.notes,
            delivered: project.delivered,
            paid: project.paid,
            dateOpened: project.dateOpened,
            dateDelivered: project.dateDelivered,
            dateClosed: project.dateClosed,
            clientName: project.client?.fullName ?? "",
            clientEmail: project.client?.email ?? "",
            clientPhone: project.client?.phone ?? "",
            clientCompany: project.client?.company ?? "",
            items: itemBackups,
            invoiceNumber: project.invoice?.number,
            invoiceName: project.invoice?.name
        )
    }
    
    private static func createClientBackup(from client: Client) -> ClientBackup {
        return ClientBackup(
            id: client.id.uuidString,
            firstName: client.firstName,
            lastName: client.lastName,
            email: client.email,
            phone: client.phone,
            company: client.company,
            address: client.address,
            city: client.city,
            state: client.state,
            zip: client.zip,
            notes: client.notes
        )
    }
    
    // MARK: - Export Functions
    
    static func exportToJSON(_ backup: FullBackup) -> URL? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        do {
            let data = try encoder.encode(backup)
            let filename = "ledger8_backup_\(backup.backupDate.formatted(.iso8601.year().month().day())).json"
            let url = URL.documentsDirectory.appending(path: filename)
            try data.write(to: url)
            print("JSON backup saved to: \(url.path)")
            return url
        } catch {
            print("JSON export failed: \(error)")
            return nil
        }
    }
    
    static func exportToCSV(_ backup: FullBackup) -> [URL] {
        var exportedFiles: [URL] = []
        
        // Export projects to CSV
        if let projectsCSV = createProjectsCSV(backup.projects) {
            exportedFiles.append(projectsCSV)
        }
        
        // Export clients to CSV  
        if let clientsCSV = createClientsCSV(backup.clients) {
            exportedFiles.append(clientsCSV)
        }
        
        return exportedFiles
    }
    
    private static func createProjectsCSV(_ projects: [ProjectBackup]) -> URL? {
        var csv = "Project Name,Artist,Start Date,End Date,Media Type,Status,Fee Total,Client Name,Client Email,Items Count\n"
        
        for project in projects {
            let feeTotal = project.items.map(\.fee).reduce(0, +)
            let itemsCount = project.items.count
            
            let row = [
                escapeCSV(project.projectName ?? ""),
                escapeCSV(project.artist ?? ""),
                project.startDate.formatted(.iso8601.year().month().day()),
                project.endDate.formatted(.iso8601.year().month().day()),
                project.mediaType,
                project.status,
                String(format: "%.2f", feeTotal),
                escapeCSV(project.clientName),
                escapeCSV(project.clientEmail),
                String(itemsCount)
            ].joined(separator: ",")
            
            csv += row + "\n"
        }
        
        let filename = "ledger8_projects_\(Date().formatted(.iso8601.year().month().day())).csv"
        let url = URL.documentsDirectory.appending(path: filename)
        
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("Projects CSV export failed: \(error)")
            return nil
        }
    }
    
    private static func createClientsCSV(_ clients: [ClientBackup]) -> URL? {
        var csv = "Name,Email,Phone,Company,Address,City,State,Zip\n"
        
        for client in clients {
            let fullName = "\(client.firstName ?? "") \(client.lastName ?? "")".trimmingCharacters(in: .whitespaces)
            let row = [
                escapeCSV(fullName),
                escapeCSV(client.email ?? ""),
                escapeCSV(client.phone ?? ""),
                escapeCSV(client.company ?? ""),
                escapeCSV(client.address ?? ""),
                escapeCSV(client.city ?? ""),
                escapeCSV(client.state ?? ""),
                escapeCSV(client.zip ?? "")
            ].joined(separator: ",")
            
            csv += row + "\n"
        }
        
        let filename = "ledger8_clients_\(Date().formatted(.iso8601.year().month().day())).csv"
        let url = URL.documentsDirectory.appending(path: filename)
        
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("Clients CSV export failed: \(error)")
            return nil
        }
    }
    
    private static func escapeCSV(_ string: String) -> String {
        if string.contains(",") || string.contains("\"") || string.contains("\n") {
            return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return string
    }
}

// MARK: - ShareSheet for exporting files
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
