//
//  NewBudgetView.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

struct NewBudgetView: View {

    @State private var budgetKind: Budget.Kind = .expense
    @State private var budgetName: String = ""
    @State private var budgetSystemIcon: SystemIcon = .default
    @State private var budgetSlices: [BudgetSlice] = []

    @State private var isInsertNewBudgetSlicePresented: Bool = false
    @State private var submitError: DomainError?

    let year: Int
    let onSubmit: (Budget) async throws -> Void

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Kind", selection: $budgetKind) {
                        ForEach(Budget.Kind.allCases, id: \.self) { kind in
                            switch kind {
                            case .expense:
                                Text("Expense")
                            case .income:
                                Text("Income")
                            }
                        }
                    }

                    HStack {
                        TextField("Name", text: $budgetName)
                            .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.nameInputField)

                        SystemIconPicker(selection: $budgetSystemIcon, label: "Icon")
                    }
                }

                Section(header: Text("Slices")) {
                    HStack {
                        Text("Total")
                        AmountView(amount: budgetSlices.totalAmount)
                    }
                    .font(.headline.bold())
                    .cornerRadius(12, antialiased: true)

                    SlicesList(slices: $budgetSlices, onAdd: {
                        isInsertNewBudgetSlicePresented = true
                    })
                }

                Section {
                    if let error = submitError {
                        InlineErrorView(error: error)
                    }

                    Button("Save", action: submit)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.saveButton)
                }
            }
            .sheet(isPresented: $isInsertNewBudgetSlicePresented) {
                NewBudgetSliceView(onSubmit: add(slice:))
            }
            .navigationTitle("New budget")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Private helper methods

    private func add(slice: BudgetSlice) async throws {
        try BudgetValidator.willAdd(slice: slice, to: budgetSlices)
        budgetSlices.append(slice)
        isInsertNewBudgetSlicePresented = false
    }

    private func submit() {
        Task {
            do {
                let budget = try Budget(
                    id: .init(),
                    year: year,
                    kind: budgetKind,
                    name: budgetName,
                    icon: budgetSystemIcon,
                    slices: budgetSlices
                )

                try await onSubmit(budget)
                submitError = nil
            } catch {
                submitError = error as? DomainError
            }
        }
    }
}

private struct SlicesList: View {

    @Binding var slices: [BudgetSlice]

    var onAdd: () -> Void

    var body: some View {
        List {
            ForEach(slices) { slice in
                BudgetSlicesListItem(slice: slice, totalBudgetAmount: slices.totalAmount)
                    .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.sliceItem)
            }
            .onDelete(perform: deleteSlices(at:))

            Button(action: onAdd) {
                Label("Add", systemImage: "plus")
            }
            .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.addSliceButton)
        }
    }

    private func deleteSlices(at indices: IndexSet) {
        indices.forEach({ slices.remove(at: $0) })
    }
}

// MARK: - Previews

struct NewBudgetView_Previews: PreviewProvider {

    static var previews: some View {
        NewBudgetView(year: 2022) { _ in }
    }
}
