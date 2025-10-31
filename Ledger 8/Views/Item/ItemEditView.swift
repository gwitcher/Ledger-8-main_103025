//
//  ItemEditView.swift
//  Ledger 8
//
//  Created by Gabe Witcher on 4/16/25.
//

import SwiftUI
import SwiftData

struct ItemEditView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var item: Item
    
    @State private var name = ""
    @State private var itemType = ItemType.overdub
    @State private var fee = Double("")
    @State private var notes = ""
    @State private var showValidationSummary = false
    
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
            errors.append(ValidationBannerError(fieldName: "Item Name", message: nameError, icon: "doc.text"))
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
                        TextField("Item Name", text: $name)
                            .textContentType(.name)
                            .submitLabel(.next)
                            .focused($focusField, equals: .itemName)
                            .onSubmit {
                                moveToNextField(.fee)
                            }
                            .onChange(of: name) {
                                // Dismiss banner if name is no longer empty
                                if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    nameValidationError = nil
                                    checkAndHideValidationSummary()
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
                .onAppear {
                    name = item.name
                    itemType = item.itemType
                    fee = item.fee
                    notes = item.notes
                }
                
            }
        }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", systemImage: "checkmark.circle.fill") {
                        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            nameValidationError = "Item name is required"
                            withAnimation(.easeIn(duration: 0.3)) {
                                showValidationSummary = true
                            }
                            return
                        }
                        item.name = name
                        item.itemType = itemType
                        item.fee = fee ?? .zero
                        dismiss()
                        
                    }
                }
            }
        }
    }
    
    /// Smoothly transitions focus to the next field to prevent keyboard flickering
    private func moveToNextField(_ nextField: ItemField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focusField = nextField
        }
    }
    
}

#Preview {
    ItemEditView(item: Item(name: "", fee: 0.0))
}
