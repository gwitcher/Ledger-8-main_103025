//
//  MockDataGenerator.swift
//  Ledger 8 Tests
//
//  Created for Phase 0 - Critical Foundation fixes
//

import Foundation
@testable import Ledger_8

// MARK: - Mock Data Generator
struct MockDataGenerator {
    
    // MARK: - Client Mock Data
    static func createMockClient(
        firstName: String = "John",
        lastName: String = "Doe", 
        email: String = "john.doe@example.com",
        phone: String = "1234567890",
        company: String = "Test Studios"
    ) -> Client {
        return Client(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            company: company
        )
    }
    
    static func createMockClients() -> [Client] {
        return [
            createMockClient(firstName: "John", lastName: "Doe", email: "john@example.com", company: "ABC Studios"),
            createMockClient(firstName: "Jane", lastName: "Smith", email: "jane@example.com", company: "XYZ Records"),
            createMockClient(firstName: "Bob", lastName: "Johnson", email: "bob@example.com", company: "Rock Productions"),
            createMockClient(firstName: "", lastName: "", email: "info@company.com", company: "Corporate Client"),
            createMockClient(firstName: "Solo", lastName: "Artist", email: "solo@example.com", company: "")
        ]
    }
    
    // MARK: - Item Mock Data
    static func createMockItem(
        name: String = "Recording Session",
        fee: Double = 150.0,
        itemType: ItemType = .session,
        notes: String = "Test session"
    ) -> Item {
        return Item(name: name, fee: fee, itemType: itemType, notes: notes)
    }
    
    static func createMockItems() -> [Item] {
        return [
            createMockItem(name: "Recording Session", fee: 150.0, itemType: .session),
            createMockItem(name: "Overdub Session", fee: 75.0, itemType: .overdub),
            createMockItem(name: "Live Concert", fee: 500.0, itemType: .concert),
            createMockItem(name: "String Arrangement", fee: 300.0, itemType: .arrangement),
            createMockItem(name: "Mixing Session", fee: 200.0, itemType: .session),
            createMockItem(name: "Equipment Rental", fee: 50.0, itemType: .rental)
        ]
    }
    
    // MARK: - Project Mock Data
    static func createMockProject(
        projectName: String = "Film Score Project",
        artist: String = "John Composer",
        mediaType: MediaType = .film,
        status: Status = .open,
        items: [Item]? = nil
    ) -> Project {
        let project = Project(
            projectName: projectName,
            artist: artist,
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600), // 1 hour later
            status: status,
            mediaType: mediaType
        )
        
        if let items = items {
            project.items = items
        }
        
        return project
    }
    
    static func createMockProjects() -> [Project] {
        let mockItems = createMockItems()
        
        return [
            createMockProject(
                projectName: "Action Movie Score",
                artist: "Hans Zimmer Style",
                mediaType: .film,
                status: .open,
                items: Array(mockItems[0...1])
            ),
            createMockProject(
                projectName: "Jazz Album Recording",
                artist: "Miles Davis Tribute",
                mediaType: .recording,
                status: .delivered,
                items: Array(mockItems[2...3])
            ),
            createMockProject(
                projectName: "TV Series Theme",
                artist: "John Williams Inspired",
                mediaType: .tv,
                status: .closed,
                items: Array(mockItems[4...5])
            ),
            createMockProject(
                projectName: "Video Game OST",
                artist: "Nobuo Uematsu Style",
                mediaType: .game,
                status: .open,
                items: [mockItems[0]]
            ),
            createMockProject(
                projectName: "Symphony Concert",
                artist: "Classical Composer",
                mediaType: .concert,
                status: .delivered,
                items: [mockItems[2], mockItems[3], mockItems[4]]
            )
        ]
    }
    
    // MARK: - Invoice Mock Data
    static func createMockInvoice(
        number: Int = 1001,
        name: String = "Invoice_1001_TestClient.pdf"
    ) -> Invoice {
        return Invoice(number: number, name: name)
    }
    
    static func createMockInvoices() -> [Invoice] {
        return [
            createMockInvoice(number: 1001, name: "Invoice_1001_JohnDoe.pdf"),
            createMockInvoice(number: 1002, name: "Invoice_1002_JaneSmith.pdf"),
            createMockInvoice(number: 1003, name: "Invoice_1003_BobJohnson.pdf")
        ]
    }
    
    // MARK: - UserData Mock Data
    static func createMockUserData() -> UserData {
        var userData = UserData()
        
        // Set up company info
        userData.company.name = "Test Music Studio"
        userData.company.address = "123 Music Lane"
        userData.company.city = "Nashville"
        userData.company.state = "TN"
        userData.company.zip = "37201"
        userData.company.phone = "1234567890"
        userData.company.email = "test@example.com"
        
        // Set up banking info
        userData.bankingInfo.venmo = "@testuser"
        userData.bankingInfo.zelle = "test@example.com"
        
        // Set up user info
        userData.userFirstName = "Test"
        userData.userLastName = "User"
        
        return userData
    }
    
    // MARK: - Complex Scenario Mock Data
    
    /// Creates a complete project with client, items, and invoice
    static func createCompleteProject() -> (project: Project, client: Client, items: [Item], invoice: Invoice) {
        let client = createMockClient()
        let items = Array(createMockItems()[0...2]) // First 3 items
        let invoice = createMockInvoice()
        
        let project = createMockProject(
            projectName: "Complete Film Score",
            artist: "John Williams",
            mediaType: .film,
            status: .closed,
            items: items
        )
        
        project.client = client
        project.invoice = invoice
        
        return (project, client, items, invoice)
    }
    
    /// Creates multiple related projects for the same client
    static func createRelatedProjectsForClient() -> (client: Client, projects: [Project]) {
        let client = createMockClient(
            firstName: "Steven",
            lastName: "Spielberg",
            email: "steven@amblin.com",
            company: "Amblin Entertainment"
        )
        
        let projects = [
            createMockProject(
                projectName: "Jurassic World Score",
                artist: "Michael Giacchino",
                mediaType: .film,
                status: .closed
            ),
            createMockProject(
                projectName: "Indiana Jones Theme",
                artist: "John Williams",
                mediaType: .film,
                status: .closed
            ),
            createMockProject(
                projectName: "E.T. Additional Music",
                artist: "John Williams",
                mediaType: .film,
                status: .delivered
            )
        ]
        
        // Link all projects to the client
        projects.forEach { $0.client = client }
        
        return (client, projects)
    }
    
    // MARK: - Edge Case Mock Data
    
    /// Creates data for testing edge cases
    static func createEdgeCaseData() -> (emptyProject: Project, minimalClient: Client, zeroFeeItem: Item) {
        let emptyProject = Project(
            projectName: "Empty Project",
            artist: "Unknown Artist"
        )
        
        let minimalClient = Client(
            firstName: "A",
            lastName: "B",
            email: "a@b.co"
        )
        
        let zeroFeeItem = Item(
            name: "Pro Bono Work",
            fee: 0.0,
            itemType: .session,
            notes: "Charity work"
        )
        
        return (emptyProject, minimalClient, zeroFeeItem)
    }
}

// MARK: - Test Data Helpers
extension MockDataGenerator {
    
    /// Generates random test data within reasonable bounds
    static func randomFee() -> Double {
        return Double.random(in: 50.0...1000.0)
    }
    
    static func randomMediaType() -> MediaType {
        return MediaType.allCases.randomElement() ?? .recording
    }
    
    static func randomStatus() -> Status {
        return Status.allCases.randomElement() ?? .open
    }
    
    static func randomItemType() -> ItemType {
        return ItemType.allCases.randomElement() ?? .session
    }
    
    /// Creates a project with random but valid data
    static func createRandomProject() -> Project {
        let artistNames = ["John Williams", "Hans Zimmer", "Danny Elfman", "Thomas Newman", "Alan Silvestri"]
        let projectNames = ["Epic Film Score", "Romantic Drama", "Action Thriller", "Documentary", "Animation Feature"]
        
        return createMockProject(
            projectName: projectNames.randomElement() ?? "Random Project",
            artist: artistNames.randomElement() ?? "Random Artist",
            mediaType: randomMediaType(),
            status: randomStatus(),
            items: createMockItems().shuffled().prefix(Int.random(in: 1...4)).map { $0 }
        )
    }
}