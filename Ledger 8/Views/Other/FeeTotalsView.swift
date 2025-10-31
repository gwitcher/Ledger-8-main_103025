//
//  FeeTotalsView.swift (formerly QuerryOpenView.swift)
//  Ledger 7
//
//  Created by Gabe Witcher on 4/10/25.
//  Updated: 10/30/25 - Migrated to use ProjectService
//

import SwiftUI
import SwiftData

struct FeeTotalsView: View {
    @Environment(\.modelContext) var modelContext
    @Query var projects: [Project]
    @Query(filter: #Predicate<Project> {$0.delivered == false && $0.paid == false}) var projectsOpen: [Project]
    @Query(filter: #Predicate<Project> {$0.delivered == true && $0.paid == false}) var projectsInvoiced: [Project]
    @Query(filter: #Predicate<Project> {$0.paid == true}) var projectsClosed: [Project]
    
    let sortSelection: Status
    
    
    init(sortSelection: Status) {
        self.sortSelection = sortSelection
        switch self.sortSelection {
        case .open:
            _projects = Query(filter: #Predicate<Project> {$0.delivered == false && $0.paid == false})
        case .delivered:
            _projects = Query(filter: #Predicate<Project> {$0.delivered == true && $0.paid == false})
        case .closed:
            _projects = Query(filter: #Predicate<Project> {$0.paid == true})
        }
    }
    
    var body: some View {
        
        
        
        HStack {
            let openTotal = ProjectService.projectsFeeTotal(projects: projectsOpen)
            let invoicedTotal = ProjectService.projectsFeeTotal(projects: projectsInvoiced)
            let closedTotal = ProjectService.projectsFeeTotal(projects: projectsClosed)
            
            VStack (alignment: .leading, spacing: 8) {
                Group {
                    switch sortSelection {
                    case .open:
                        Text("^[\(projects.count) \(sortSelection.feeTotalLabel)](inflect: true)")
                    case .delivered:
                        Text("^[\(projects.count) \(sortSelection.feeTotalLabel)](inflect: true) DUE")
                    case .closed:
                        Text("^[\(projects.count) \(sortSelection.feeTotalLabel)](inflect: true) PAID")
                    }
                    
                    
//                    if sortSelection == .delivered {
//                        Text("^[\(projects.count) \(sortSelection.feeTotalLabel)](inflect: true) DUE")
//                    } else {
//                        Text("^[\(projects.count) \(sortSelection.feeTotalLabel)](inflect: true)")
//                    }
                }
                .font(.headline)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal)
                
                Text("\(ProjectService.projectsFeeTotal(projects: projects).formatted(.currency(code: "USD")))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(sortSelection.statusColor)
                    .padding([.bottom, .horizontal])
                
            }
            .background(Color.clear)
            //.animation(.easeInOut(duration: 0.3), value: sortSelection)
            
            Spacer()
            
            Group {
                
                switch sortSelection {
                case .open:
                    VStack (alignment: .trailing, spacing: 8) {
                        Text("\(invoicedTotal.formatted(.currency(code: "USD")))")
                            .font(.subheadline)
                            .foregroundStyle(Status.delivered.statusColorDark)
                        Text("\(closedTotal.formatted(.currency(code: "USD")))")
                            .font(.subheadline)
                            .foregroundStyle(Status.closed.statusColor)
                    }
                    .fontWeight(.bold)
                    .padding([.horizontal, .bottom])
                    
                case .delivered:
                    VStack (alignment: .trailing, spacing: 8) {
                        Text("\(openTotal.formatted(.currency(code: "USD")))")
                            .font(.subheadline)
                            .foregroundStyle(Status.open.statusColorDark)
                        Text("\(closedTotal.formatted(.currency(code: "USD")))")
                            .font(.subheadline)
                            .foregroundStyle(Status.closed.statusColor)
                    }
                    .fontWeight(.bold)
                    .padding([.horizontal, .bottom])
                    
                case .closed:
                    VStack (alignment: .trailing, spacing: 8) {
                        Text("\(openTotal.formatted(.currency(code: "USD")))")
                            .font(.subheadline)
                            .foregroundStyle(Status.open.statusColor)
                        Text("\(invoicedTotal.formatted(.currency(code: "USD")))")
                            .font(.subheadline)
                            .foregroundStyle(Status.delivered.statusColorDark)
                    }
                    .fontWeight(.bold)
                    .padding([.horizontal, .bottom])
                    
                }
                   
            }
            //.animation(.easeInOut(duration: 0.4), value: sortSelection)
            
        }
        //.animation(.easeIn(duration: 0.025), value: sortSelection)
        
    }
    
    // MARK: - Removed local projectsFeeTotal method
    // Now using ProjectService.projectsFeeTotal(projects:) instead
}
#Preview {
    FeeTotalsView(sortSelection: Status.open)
}

