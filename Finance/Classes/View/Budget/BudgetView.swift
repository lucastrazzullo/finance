//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    @Environment(\.editMode) private var editMode

    @ObservedObject private var controller: BudgetController

    @State private var updatingBudgetName: String
    @State private var updateBudgetNameError: DomainError?

    @State private var isInsertNewSlicePresented: Bool = false
    @State private var deleteSlicesError: DomainError?

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AmountView(amount: controller.budget.amount)
                .font(.headline)
                .padding(.horizontal)

            List {
                NameSection(
                    name: $updatingBudgetName,
                    isEditing: isEditing,
                    error: updateBudgetNameError
                )

                SlicesListSection(
                    slices: controller.budget.slices,
                    isEditing: isEditing,
                    error: deleteSlicesError,
                    onAdd: { isInsertNewSlicePresented = true },
                    onDelete: deleteSlices(at:)
                )
            }
            .listStyle(InsetListStyle())
        }
        .sheet(isPresented: $isInsertNewSlicePresented) {
            NewBudgetSliceView { newSlice in
                try await controller.add(slice: newSlice)
                isInsertNewSlicePresented = false
            }
        }
        .navigationTitle(isEditing ? updatingBudgetName : controller.budget.name)
        .toolbar { EditButton() }
        .onAppear { fetch() }
        .onChange(of: isEditing) { newVaue in
            if !newVaue {
                updateBudgetNameError = nil
                deleteSlicesError = nil
                saveUpdatedValues()
            }
        }
    }

    // MARK: Object life cycle

    init(budget: Budget, storageProvider: StorageProvider) {
        self.controller = BudgetController(budget: budget, storageProvider: storageProvider)
        self._updatingBudgetName = State<String>(wrappedValue: budget.name)
    }

    // MARK: Private helper methods

    private func fetch() {
        Task {
            try? await controller.fetch()
        }
    }

    private func saveUpdatedValues() {
        Task {
            do {
                try await controller.update(budgetName: updatingBudgetName)
                updateBudgetNameError = nil
            } catch {
                updateBudgetNameError = error as? DomainError
            }
        }
    }

    private func deleteSlices(at indices: IndexSet) {
        Task {
            do {
                try await controller.delete(slicesAt: indices)
                deleteSlicesError = nil
            } catch {
                deleteSlicesError = error as? DomainError
            }
        }
    }
}

private struct NameSection: View {

    @Binding var name: String

    let isEditing: Bool
    let error: DomainError?

    var body: some View {
        if isEditing {
            Section(header: Text("Name")) {
                TextField("Budget Name", text: $name)
                    .disabled(!isEditing)

                if let error = error {
                    InlineErrorView(error: error)
                }
            }
        }
    }
}

private struct SlicesListSection: View {

    let slices: [BudgetSlice]
    let isEditing: Bool
    let error: DomainError?

    let onAdd: () -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        Section(header: Text("Slices")) {
            if isEditing {
                ForEach(slices, id: \.id) { slice in
                    BudgetSlicesListItem(slice: slice, totalBudgetAmount: slices.totalAmount)
                }
                .onDelete(perform: onDelete)
            } else {
                ForEach(slices, id: \.id) { slice in
                    BudgetSlicesListItem(slice: slice, totalBudgetAmount: slices.totalAmount)
                }
            }

            if isEditing {
                Label("Add", systemImage: "plus")
                    .onTapGesture(perform: onAdd)
            }

            if let error = error {
                InlineErrorView(error: error)
            }
        }
    }
}

// MARK: - Previews

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        let storageProvider = MockStorageProvider()
        NavigationView {
            BudgetView(budget: Mocks.budgets[0], storageProvider: storageProvider)
        }
    }
}
