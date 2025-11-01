# Component Responsibility Matrix

*Created: October 31, 2025*  
*Analysis Phase: Week 1, Day 2*  
*Supporting Document for ProjectDetailView Refactoring*

---

## 📊 **Current vs Proposed Responsibility Distribution**

### **Responsibility Mapping Table**

| Responsibility Area | Current Location | Lines | State Vars | Proposed Component | Target Lines | Target State |
|-------------------|------------------|--------|------------|-------------------|--------------|--------------|
| **Client Management** | `clientSection` | ~150 | 3 | `ProjectClientSelection` | ~100 | 2 |
| **Project Name/Artist** | `projectInfoSection` | ~200 | 6 | `ProjectBasicInfoForm` | ~150 | 4 |
| **Date/Time Pickers** | `expandingDateFields` | ~300 | 8 | `ProjectDateTimeManager` | ~250 | 6 |
| **Project Suggestions** | `projectSuggestionsList` | ~100 | 2 | `ProjectSuggestionsView` | ~150 | 3 |
| **Status Controls** | `statusSection` | ~100 | 5 | `ProjectStatusControls` | ~120 | 5 |
| **Validation Logic** | Scattered | ~150 | 13 | `ProjectValidationViewModel` | ~200 | 8 |
| **Navigation/Actions** | `toolbarContent` | ~100 | 4 | `ProjectFormToolbar` | ~100 | 3 |
| **Form Coordination** | `body` + methods | ~126 | 13 | `ProjectDetailView` (refactored) | ~200 | 6 |

---

## 🎯 **Single Responsibility Principle Analysis**

### **Component 1: ProjectClientSelection**
#### **Single Responsibility:** Client selection and display with validation feedback

**Current Violations:**
- Mixed with project suggestions logic
- Validation scattered across view
- Sheet presentation logic embedded

**After Refactoring:**
- ✅ **Pure Responsibility:** Client selection UI and validation display
- ✅ **Clear Interface:** Bindings for client and sheet state
- ✅ **Testable:** All client selection logic isolated

```swift
// Focused Interface
struct ProjectClientSelection: View {
    @Binding var selectedClient: Client?
    @Binding var clientSelectSheetIsPresented: Bool
    @ObservedObject var validation: ProjectValidationViewModel
    
    // Single responsibility: Client selection with validation
}
```

### **Component 2: ProjectBasicInfoForm**
#### **Single Responsibility:** Project name and artist input with validation

**Current Violations:**
- Date logic mixed in same section
- Suggestions logic intertwined
- Focus management scattered

**After Refactoring:**
- ✅ **Pure Responsibility:** Text field input with validation
- ✅ **Clear Interface:** Bindings for text values and validation model
- ✅ **Testable:** Text input validation logic isolated

```swift
// Focused Interface  
struct ProjectBasicInfoForm: View {
    @Binding var projectName: String
    @Binding var artist: String
    @ObservedObject var validation: ProjectValidationViewModel
    @FocusState private var focusedField: ProjectField?
    
    // Single responsibility: Text input with validation
}
```

### **Component 3: ProjectDateTimeManager**
#### **Single Responsibility:** Date and time selection with complex UI

**Current Violations:**
- Scroll logic mixed with date logic
- Validation embedded in UI components
- Focus management affects other components

**After Refactoring:**
- ✅ **Pure Responsibility:** Date/time picker UI and behavior
- ✅ **Clear Interface:** Bindings for dates, callbacks for coordination
- ✅ **Testable:** Date picker logic and validation separated

```swift
// Focused Interface
struct ProjectDateTimeManager: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @ObservedObject var validation: ProjectValidationViewModel
    let onScrollNeeded: (ScrollTarget) -> Void
    
    // Single responsibility: Date/time selection UI
}
```

### **Component 4: ProjectSuggestionsView**  
#### **Single Responsibility:** Template project suggestions with smart filtering

**Current Violations:**
- UI and business logic mixed
- Client dependency not clearly defined
- Sorting algorithm embedded in view

**After Refactoring:**
- ✅ **Pure Responsibility:** Template suggestions with filtering
- ✅ **Clear Interface:** Dependencies clearly defined
- ✅ **Testable:** Filtering and sorting logic separated

```swift
// Focused Interface
struct ProjectSuggestionsView: View {
    @Binding var showSuggestions: Bool
    @Binding var selectedTemplate: Project?
    let allProjects: [Project]
    let selectedClient: Client?
    let onTemplateSelected: (Project) -> Void
    
    // Single responsibility: Template suggestions
}
```

### **Component 5: ProjectStatusControls**
#### **Single Responsibility:** Delivery and payment status management

**Current Violations:**
- Status derivation logic mixed with UI
- Date management scattered
- Business rules embedded in toggles

**After Refactoring:**
- ✅ **Pure Responsibility:** Status toggle UI with business logic
- ✅ **Clear Interface:** Bindings for all status-related state
- ✅ **Testable:** Status transition logic isolated

```swift
// Focused Interface
struct ProjectStatusControls: View {
    @Binding var delivered: Bool
    @Binding var paid: Bool
    @Binding var dateDelivered: Date
    @Binding var dateClosed: Date
    let onStatusChange: () -> Void
    
    // Single responsibility: Status management
}
```

### **Component 6: ProjectValidationViewModel**
#### **Single Responsibility:** Centralized validation state and logic

**Current Violations:**
- Validation logic scattered across 1,126 lines
- State management mixed with UI updates
- Business rules embedded in view methods

**After Refactoring:**
- ✅ **Pure Responsibility:** Validation state management and rules
- ✅ **Clear Interface:** Observable validation state and methods
- ✅ **Testable:** Pure validation functions with comprehensive tests

```swift
// Focused Interface
@Observable class ProjectValidationViewModel {
    private(set) var validationErrors: [ProjectField: String] = [:]
    private(set) var hasErrors: Bool = false
    
    // Single responsibility: Validation logic and state
    func validateField(_ field: ProjectField, value: Any) -> Bool
    func validateAllFields() -> Bool
}
```

### **Component 7: ProjectFormToolbar**
#### **Single Responsibility:** Form navigation and actions

**Current Violations:**
- Validation logic embedded in button actions
- Save logic mixed with UI logic
- Error handling scattered

**After Refactoring:**
- ✅ **Pure Responsibility:** Navigation actions and validation integration
- ✅ **Clear Interface:** Callbacks for actions, validation dependency
- ✅ **Testable:** Action logic separated from business logic

```swift
// Focused Interface
struct ProjectFormToolbar: View {
    let onSave: () -> Bool
    let onCancel: () -> Void
    @ObservedObject var validation: ProjectValidationViewModel
    
    // Single responsibility: Form actions with validation
}
```

---

## 📊 **State Management Optimization**

### **Current State Coupling Matrix**

| State Variable | Affects | Affected By | Coupling Score |
|----------------|---------|-------------|----------------|
| `validationState` | 4 error states | All form fields | **High (9)** |
| `showValidationSummary` | Banner display | 4 error states | **High (8)** |
| `focusField` | 4 picker states | All input fields | **High (7)** |
| `selectedClient` | Suggestions, validation | Client selection | **Medium (3)** |
| `startDate` | End date, validation | Date pickers | **Medium (4)** |
| `endDate` | Start date, validation | Date pickers | **Medium (4)** |
| `delivered` | Status, dates | Toggle actions | **Medium (3)** |
| `paid` | Status, dates | Toggle actions | **Medium (3)** |

### **Proposed State Distribution**

#### **ProjectValidationViewModel (8 state variables)**
```swift
// Centralized validation state
private(set) var validationErrors: [ProjectField: String] = [:]
private(set) var focusedFields: Set<ProjectField> = []
private(set) var actionTriggeredFields: Set<ProjectField> = []
private(set) var hasErrors: Bool = false
private(set) var shouldShowSummary: Bool = false
var summaryErrors: [ValidationBannerError] { get }
var currentError: LedgerError? { get }
var isValid: Bool { get }
```

#### **ProjectFormCoordinator (8 state variables)**
```swift
// Core form data
var projectName: String = ""
var artist: String = ""
var startDate: Date = Date()
var endDate: Date = Date()
var mediaType: MediaType = .recording
var notes: String = ""
var selectedClient: Client?
var selectedTemplateProject: Project?
```

#### **Component-Specific State (Distributed)**
```swift
// ProjectDateTimeManager (6 variables)
@State private var showStartDatePicker = false
@State private var showStartTimePicker = false  
@State private var showEndDatePicker = false
@State private var showEndTimePicker = false
@State private var endDateSelected = false
@FocusState private var focusedField: ProjectField?

// ProjectClientSelection (1 variable)
@State private var clientSelectSheetIsPresented = false

// ProjectStatusControls (4 variables)  
@State private var delivered = false
@State private var paid = false
@State private var dateDelivered = Date()
@State private var dateClosed = Date()
```

---

## 🔄 **Component Communication Patterns**

### **Data Flow Architecture**

```
ProjectDetailView (Container)
│
├── ProjectFormCoordinator (Business Logic)
│   ├── Core form data (name, artist, dates, etc.)
│   ├── Business operations (save, load, apply template)
│   └── Status management (delivered, paid, status derivation)
│
├── ProjectValidationViewModel (Validation Logic)
│   ├── Field validation rules
│   ├── Error state management
│   └── Validation UI coordination
│
└── Child Components (UI Specialized)
    ├── ProjectBasicInfoForm
    │   └── Bindings: projectName, artist
    ├── ProjectClientSelection  
    │   └── Bindings: selectedClient, sheet state
    ├── ProjectDateTimeManager
    │   └── Bindings: startDate, endDate + local UI state
    ├── ProjectSuggestionsView
    │   └── Bindings: showSuggestions, selectedTemplate
    ├── ProjectStatusControls
    │   └── Bindings: delivered, paid, dates
    └── ProjectFormToolbar
        └── Callbacks: onSave, onCancel + validation dependency
```

### **Event Handling Pattern**

#### **Current (Problematic)**
```swift
// Events scattered across view with tight coupling
TextField("", text: $projectName)
    .onChange(of: projectName) { 
        validateProjectNameField(projectName)  // Direct coupling
        showProjectSuggestions = checkSuggestions() // Side effects
        updateUI() // More side effects
    }
```

#### **Proposed (Clean)**
```swift
// Events handled by coordinators with clear interfaces
TextField("", text: $coordinator.projectName)
    .onChange(of: coordinator.projectName) { 
        validation.validateField(.projectName, value: $0) // Single responsibility
    }

// Side effects handled at coordinator level
coordinator.$projectName
    .sink { newName in
        suggestions.updateVisibility(for: newName, client: coordinator.selectedClient)
    }
```

---

## 🧪 **Testability Improvements**

### **Current Testing Challenges**
- **Monolithic View:** Cannot test individual responsibilities in isolation
- **State Coupling:** Changes in one area affect multiple unrelated areas  
- **Mixed Concerns:** Business logic embedded in view logic
- **No Clear Interfaces:** Difficult to mock dependencies

### **Post-Refactoring Testing Strategy**

#### **Unit Tests (High Coverage Possible)**
```swift
// ProjectValidationViewModel Tests
@Test func validateProjectName_whenEmpty_returnsError()
@Test func validateDateRange_whenStartAfterEnd_returnsError() 
@Test func validateAllFields_withValidData_returnsTrue()

// ProjectFormCoordinator Tests  
@Test func applyTemplate_copiesAllFields()
@Test func saveToProject_withValidData_returnsTrue()
@Test func loadFromProject_populatesAllFields()

// Component Tests
@Test func projectBasicInfoForm_withInvalidName_showsError()
@Test func projectClientSelection_whenNoClient_showsAddButton()
```

#### **UI Tests (Focused Workflows)**
```swift
// Each component can be tested independently
@Test func projectCreation_completeWorkflow_savesSuccessfully()
@Test func validation_showsErrorsCorrectly()  
@Test func clientSelection_updatesFormCorrectly()
```

#### **Integration Tests (Component Interaction)**
```swift
@Test func formCoordination_betweenComponents_worksCorrectly()
@Test func validationIntegration_acrossComponents_showsConsistentState()
```

---

## 📊 **Complexity Metrics Comparison**

### **Before Refactoring**

| Metric | Current Value | Risk Level |
|--------|---------------|------------|
| **Lines per Component** | 1,126 (monolith) | 🔴 **Critical** |
| **Cyclomatic Complexity** | ~45 (estimated) | 🔴 **Critical** |  
| **State Variables** | 54 in one view | 🔴 **Critical** |
| **Responsibilities** | 7 major areas | 🔴 **Critical** |
| **Test Coverage** | 0% (untestable) | 🔴 **Critical** |
| **Coupling Score** | High (9/10) | 🔴 **Critical** |

### **After Refactoring (Projected)**

| Component | Lines | Complexity | State Vars | Risk Level |
|-----------|-------|------------|------------|------------|
| **ProjectBasicInfoForm** | ~150 | ~8 | 4 | 🟢 **Low** |
| **ProjectClientSelection** | ~100 | ~5 | 2 | 🟢 **Low** |  
| **ProjectDateTimeManager** | ~250 | ~12 | 6 | 🟡 **Medium** |
| **ProjectSuggestionsView** | ~150 | ~8 | 3 | 🟢 **Low** |
| **ProjectStatusControls** | ~120 | ~6 | 5 | 🟢 **Low** |
| **ProjectValidationViewModel** | ~200 | ~10 | 8 | 🟡 **Medium** |
| **ProjectFormToolbar** | ~100 | ~5 | 3 | 🟢 **Low** |
| **ProjectDetailView (refactored)** | ~200 | ~8 | 6 | 🟢 **Low** |

### **Overall Improvement**
- **Largest Component:** 1,126 → 250 lines (78% reduction)
- **Average Complexity:** 45 → 8 (82% reduction)
- **Max State Variables:** 54 → 8 per component (85% reduction)
- **Testability:** 0% → 80%+ coverage possible
- **Maintainability:** Critical → Low/Medium risk

---

## 🎯 **Implementation Priority Matrix**

### **High Priority (Week 2, Days 1-2)**
1. **ProjectValidationViewModel** - Foundation for all other components
2. **ProjectBasicInfoForm** - Core functionality, clear boundaries
3. **ProjectClientSelection** - Simple UI, well-defined scope

### **Medium Priority (Week 2, Days 3-4)**
4. **ProjectStatusControls** - Straightforward business logic
5. **ProjectSuggestionsView** - Enhanced functionality, manageable complexity
6. **ProjectFormToolbar** - Action coordination, Apple design integration

### **High Risk/Complexity (Week 2, Day 5)**
7. **ProjectDateTimeManager** - Complex UI state, requires careful extraction

### **Integration (Week 4)**
8. **ProjectDetailView Rebuild** - Compose all components with coordinator

---

## 📋 **Success Criteria Checklist**

### **Component Quality Gates**
- [ ] **Single Responsibility:** Each component has one clear purpose
- [ ] **Line Count:** No component exceeds 300 lines
- [ ] **State Management:** No component has more than 8 state variables
- [ ] **Testability:** Each component can be unit tested in isolation
- [ ] **Interface Clarity:** All dependencies clearly defined in init/bindings
- [ ] **Documentation:** Each component has clear responsibility documentation

### **Architecture Quality Gates**
- [ ] **Loose Coupling:** Components communicate through well-defined interfaces
- [ ] **High Cohesion:** Related functionality grouped within components
- [ ] **Clear Data Flow:** Single source of truth for shared state
- [ ] **Separation of Concerns:** UI, business logic, and validation clearly separated
- [ ] **Apple Standards:** Modern SwiftUI patterns and design system integration

---

*This responsibility matrix provides the blueprint for systematic component extraction, ensuring each new component has a clear, focused responsibility that can be developed, tested, and maintained independently.*