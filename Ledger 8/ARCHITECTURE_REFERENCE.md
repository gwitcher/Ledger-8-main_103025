# Ledger 8 - Complete Architecture Reference

*Last Updated: October 30, 2025*
*A comprehensive freelance musician gig management app built with SwiftUI and SwiftData*

---

## 📱 **App Overview**
**Purpose:** Help freelance musicians track gigs through their complete lifecycle - from booking to delivery to invoicing to payment.

**Tech Stack:** SwiftUI, SwiftData, Swift 6.0+, iOS

**Database:** SwiftData with custom "GigTracker" database name

---

## 🗂️ **Complete File Structure**

### **Core App Files**
- `Ledger_8App.swift` - Main app entry point, SwiftData container configuration
- `ContentView.swift` - Root navigation view, displays ProjectListView
- `.gitignore` - Xcode/Swift project gitignore configuration

### **📊 Data Models (`Models/` folder)**
- `Project.swift` - Core project entity with status lifecycle, dates, relationships
- `Client.swift` - Contact management (personal, company, address info)  
- `Item.swift` - Billable services/items with fees and ItemType categorization
- `Invoice.swift` - PDF invoice generation with URL storage and numbering
- `User.swift` - UserData struct for app settings (Company, BankingInfo, user details)

### **🎯 Enums & Types**
- `Enums.swift` - All app enums:
  - `Status` - Project lifecycle (Open, Delivered, Paid) with color coding
  - `MediaType` - Project categories (Film, TV, Recording, Game, Concert, Tour, Lesson, Other)
  - `ItemType` - Billable service types (Session, Overdub, Concert, Arrangement, etc.)
  - `ProjectField`, `ItemField`, `clientField`, `userField`, `bankField` - Focus state management

### **🎨 UI Views - Project Management**
- `ProjectListView.swift` - Main dashboard with project filtering by status
- `ProjectDetailView.swift` - Full project creation/editing form (871 lines)
- `ProjectView.swift` - Individual project card display
- `SortedProjectView.swift` - Filtered project lists with swipe actions and monthly grouping

### **👥 UI Views - Client Management**  
- `ClientListView.swift` - Client directory with search/management
- `ClientSelectView.swift` - Client picker for projects
- `NewClientView.swift` - Client creation form (265 lines)
- `PayerView.swift` - Client payment information view

### **💰 UI Views - Items & Billing**
- `ItemListView.swift` - List of billable items for projects
- `ItemListView2.swift` - Alternative item list implementation  
- `ItemDetailView.swift` - Item creation/editing form (120 lines)
- `ItemEditView.swift` - Item modification interface (110 lines)
- `ItemView.swift` - Individual item display card

### **🧾 UI Views - Invoicing**
- `InvoiceTemplateView.swift` - PDF invoice layout template (104 lines)
- `InvoiceLinkView.swift` - Invoice file management and sharing
- `AddInvoiceView.swift` - Invoice creation interface
- `ShowInvoice.swift` - Invoice preview and display
- `BankingInvoiceView.swift` - Banking info display on invoices

### **⚙️ UI Views - Settings**
- `SettingsView.swift` - Main settings navigation hub
- `UserNameView.swift` - User personal info editing
- `CompanyInfoView.swift` - Company details form (99 lines)
- `BankingInfoView.swift` - Banking and payment app info (78 lines)
- `CompanyLogoView.swift` - Logo display component

### **📈 UI Views - Analytics**
- `Charts.swift` - Main analytics dashboard
- `IncomeByMonthView.swift` - Monthly income visualization (528 lines)
- `MediaTypeDonutChartView.swift` - Project type breakdown chart (232 lines)
- `FeeTotalsView.swift` - Status-based fee summaries

### **🚀 UI Views - Onboarding & Misc**
- `OnboardingView.swift` - First-run setup experience (245 lines)
- `Onboarding.swift` - Additional onboarding components (571 lines)
- `MainView.swift` - Alternative main view implementation

### **🔧 Utilities & Extensions**
- `Extensions.swift` - Project calculations, invoice generation, Date helpers, View extensions (103 lines)

### **📋 Documentation**
- `DevelopmentSuggestions.md` - Development roadmap and improvement suggestions (90 lines)
- `ARCHITECTURE_REFERENCE.md` - This comprehensive architecture document

---

## 🏗️ **Data Architecture**

### **Core Entity Relationships**
```
Project (1) ←→ (0..1) Client
Project (1) ←→ (0..*) Item  [cascade delete]
Project (1) ←→ (0..1) Invoice [cascade delete]
```

### **SwiftData Schema**
```swift
// CURRENT (Potential Issue)
let schema = Schema([Project.self])

// SHOULD BE
let schema = Schema([Project.self, Client.self, Item.self, Invoice.self])
```

### **Data Persistence**
- **SwiftData:** Core project/client/item data
- **@AppStorage:** User preferences, company info, banking details
- **File System:** Generated PDF invoices in Documents directory

---

## 🎯 **Key Features Implemented**

### ✅ **Project Lifecycle Management**
- Status progression: Open → Delivered → Paid
- Date tracking: dateOpened, dateDelivered, dateClosed
- Swipe actions for quick status changes
- Monthly grouping for closed projects

### ✅ **Professional Invoicing**
- PDF generation using SwiftUI ImageRenderer
- Automatic invoice numbering with persistence
- Company branding and banking info inclusion
- File storage and sharing capabilities

### ✅ **Comprehensive Billing**
- Multiple item types per project
- Automatic fee calculation and totals  
- Industry-specific item categories
- Per-project and overall financial summaries

### ✅ **Client Management**
- Full contact information storage
- Company and personal details
- Address management for invoicing
- Client-project relationship tracking

### ✅ **Analytics & Reporting**
- Income tracking by month
- Project type breakdowns (donut charts)
- Status-based fee summaries
- Visual data representation

### ✅ **User Configuration**
- Personal and company information
- Banking details for invoices
- Payment app integration (Venmo, Zelle)
- Persistent app settings

---

## 🎨 **UI Architecture Patterns**

### **Navigation Structure**
- `NavigationStack` with sheet presentations
- Full-screen covers for major workflows
- Toolbar-based action buttons
- Swipe gestures for quick actions

### **State Management**
- `@Query` for SwiftData retrieval
- `@State` for view-local state
- `@AppStorage` for persistent settings
- `@FocusState` for form management
- `@Environment` for shared resources

### **Form Handling**
- `LabeledContent` for consistent form layouts
- Field-specific focus state management
- Automatic keyboard management
- Input validation (partial implementation)

---

## 🎵 **Music Industry Specifics**

### **Project Types (MediaType)**
- Film/TV scoring
- Recording sessions  
- Live concerts
- Tours
- Music lessons
- Video game audio
- General "Other" category

### **Billable Services (ItemType)**
- Tracking sessions, overdubs
- Live performances, tours
- Arrangements and scoring
- Equipment rental
- Per diem and reimbursements
- Music lessons
- Production services

---

## 🚨 **Known Issues & Improvement Areas**

### **Critical**
- SwiftData schema missing Client, Item, Invoice models
- Force unwraps throughout codebase need error handling

### **Enhancement Opportunities**
- Form validation implementation
- Unit test coverage
- Calendar integration 
- Email functionality
- Data export capabilities
- Advanced analytics features

---

## 🔮 **Architecture Strengths**

1. **Modern SwiftUI/SwiftData:** Uses latest Apple frameworks effectively
2. **Clean Separation:** Models, views, and utilities well-organized
3. **Industry-Focused:** Built specifically for musician workflows
4. **Comprehensive:** Covers entire gig lifecycle end-to-end
5. **Professional Polish:** PDF generation, proper data relationships
6. **User-Centric:** Thoughtful UX with swipe actions, focus management

---

*This document serves as the definitive reference for Ledger 8's architecture and should be updated as the codebase evolves.*