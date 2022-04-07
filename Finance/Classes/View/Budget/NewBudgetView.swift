//
//  NewBudgetView.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

struct NewBudgetView: View {

    @State private var budgetName: String = ""
    @State private var budgetSlices: [BudgetSlice] = []

    @State private var submitError: DomainError?
    @State private var isInsertNewBudgetSlicePresented: Bool = false

    let onSubmit: (Budget) async throws -> Void

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $budgetName)
                    .accessibilityIdentifier(AccessibilityIdentifier.NewBudgetView.nameInputField)
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
            NewBudgetSliceView { newSlice in
                try Budget.willAdd(slice: newSlice, to: budgetSlices)
                budgetSlices.append(newSlice)
                isInsertNewBudgetSlicePresented = false
            }
        }
    }

    // MARK: Private helper methods

    private func submit() {
        Task {
            do {
                let budget = try Budget(name: budgetName, slices: budgetSlices)
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
        NewBudgetView { _ in }
    }
}
