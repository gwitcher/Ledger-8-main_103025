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
    @State private var showValidationBanner = false
    
    
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
                if showValidationBanner {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Please enter an item name before saving")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Button {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showValidationBanner = false
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                Form {
                Section("Item Info") {
                    LabeledContent {
                        TextField("Item Name", text: $name)
                            .textContentType(.name)
                            .focused($focusField, equals: .itemName)
                            .submitLabel(.next)
                            .onSubmit {
                                focusField = .fee
                            }
                            .onChange(of: name) {
                                // Dismiss banner if name is no longer empty
                                if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && showValidationBanner {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        showValidationBanner = false
                                    }
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
                            withAnimation(.easeIn(duration: 0.3)) {
                                showValidationBanner = true
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
