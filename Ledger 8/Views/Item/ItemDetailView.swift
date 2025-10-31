//
//  ItemDetailView.swift
//  Ledger 8
//
//  Created by Gabe Witcher on 4/15/25.
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var project: Project
    
    @State private var name = ""
    @State private var itemType = ItemType.overdub
    @State private var fee = Double("")
    @State private var notes = ""
    // MARK: - Focus-aware validation tracking
    @State private var nameHasBeenFocused = false
    @State private var showValidationSummary = false
    
    // MARK: - Action-triggered validation indicators
    @State private var showNameTriangle = false
    
    // MARK: - Validation State
    @State private var nameValidationError: String?
    
    // MARK: - Computed Properties
    
    /// Checks if there are any validation errors
    private var hasValidationErrors: Bool {
        return nameValidationError != nil
    }
    
    /// Current validation errors for display in banner
    private var currentValidationErrors: [ValidationBannerError] {
        var errors: [ValidationBannerError] = []
        
        if let nameError = nameValidationError {
            errors.append(ValidationBannerError(fieldName: "Item Name", message: nameError, icon: "circle.fill"))
        }
        
        return errors
    }
    
    /// Auto-hide validation summary when errors are resolved
    private func checkAndHideValidationSummary() {
        if showValidationSummary && !hasValidationErrors {
            withAnimation(.easeOut(duration: 0.3)) {
                showValidationSummary = false
            }
        }
    }
    
    
    @FocusState private var isFocused: Bool
    @FocusState private var focusField: ItemField?
    
    private let currencyNumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    private let decimalNumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Validation Banner
                ValidationSummaryBanner(
                    title: "Please complete required fields:",
                    validationErrors: currentValidationErrors,
                    isVisible: $showValidationSummary
                )
                
                Form {
                    Section("Item Info") {
                        LabeledContent {
                            HStack {
                                TextField("Item Name", text: $name)
                                    .textContentType(.name)
                                    .focused($focusField, equals: .itemName)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        moveToNextField(.fee)
                                    }
                                    .onChange(of: name) {
                                        // Clear validation error and hide triangle if name is no longer empty
                                        if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            nameValidationError = nil
                                            showNameTriangle = false
                                            checkAndHideValidationSummary()
                                        }
                                    }
                                    .onChange(of: focusField) { _, newValue in
                                        // Track when name field has been focused
                                        if newValue == .itemName {
                                            nameHasBeenFocused = true
                                        }
                                    }
                                
                                // Show validation triangle if triggered by action button or if field was focused and has error
                                if showNameTriangle || (nameHasBeenFocused && focusField != .itemName && nameValidationError != nil && name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                        }   label: {
                            Text("").foregroundStyle(.secondary)
                        }
                        
                        Picker(" Type", selection: $itemType) {
                            ForEach(ItemType.allCases) {type in
                                Text(type.rawValue)
                            }
                        }
                        
                        LabeledContent {
                            TextField("$ Fee", value: $fee, formatter: isFocused ? decimalNumberFormatter : currencyNumberFormatter)
                                .keyboardType(.decimalPad)
                                .focused($isFocused)
                                .focused($focusField, equals: .fee)
                            
                        } label: {
                            Text("")
                        }
                        .keyboardType(.decimalPad)
                    }
                    
                    Section("Notes") {
                        TextField("", text: $notes, axis: .vertical)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            nameValidationError = "Item name is required"
                            showNameTriangle = true // Show triangle when action button pressed
                            withAnimation(.easeIn(duration: 0.3)) {
                                showValidationSummary = true
                            }
                            return
                        }
                        saveItem(name: name, fee: fee ?? .zero, itemType: itemType, notes: notes)
                        dismiss()
                    }
                }
                
                
                ToolbarItem(placement: .keyboard){
                    Button("Submit") {
                        isFocused = false
                    }
                    
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    /// Smoothly transitions focus to the next field to prevent keyboard flickering
    private func moveToNextField(_ nextField: ItemField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focusField = nextField
        }
    }
    
    func saveItem(name: String, fee: Double, itemType: ItemType, notes: String) {
        let newItem = Item(name: name, fee: fee, itemType: itemType, notes: notes)
        
        project.items?.append(newItem)
        
        guard let _ = try? modelContext.save() else {
            print("ERROR: could not save")
            return
        }
    }
}

//#Preview {
//    ItemDetailView(item: Item())
//}
