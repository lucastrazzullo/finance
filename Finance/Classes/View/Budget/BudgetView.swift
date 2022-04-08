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
    @State private var updatingBudgetIcon: String
    @State private var updateBudgetInfoError: DomainError?

    @State private var isInsertNewSlicePresented: Bool = false
    @State private var deleteSlicesError: DomainError?

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack {
                AmountView(amount: controller.budget.amount)
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)

            List {
                InfoSection(
                    name: $updatingBudgetName,
                    icon: $updatingBudgetIcon,
                    isEditing: isEditing,
                    error: updateBudgetInfoError
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    let viewModel = BudgetViewModel(budget: controller.budget)
                    Text(isEditing ? updatingBudgetName : viewModel.name)
                    Image(systemName: isEditing ? updatingBudgetIcon : viewModel.iconSystemName)
                        .symbolRenderingMode(.hierarchical)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .onAppear { fetch() }
        .onChange(of: isEditing) { newVaue in
            if !newVaue {
                updateBudgetInfoError = nil
                deleteSlicesError = nil
                saveUpdatedValues()
            }
        }
    }

    // MARK: Object life cycle

    init(budget: Budget, storageProvider: StorageProvider) {
        self.controller = BudgetController(budget: budget, storageProvider: storageProvider)
        self._updatingBudgetName = State<String>(wrappedValue: budget.name)

        let viewModel = BudgetViewModel(budget: budget)
        self._updatingBudgetIcon = State<String>(wrappedValue: viewModel.iconSystemName)
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
                try await controller.update(budgetName: updatingBudgetName, iconSystemName: updatingBudgetIcon)
                updateBudgetInfoError = nil
            } catch {
                updateBudgetInfoError = error as? DomainError
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

private struct InfoSection: View {

    @Binding var name: String
    @Binding var icon: String

    let isEditing: Bool
    let error: DomainError?

    var body: some View {
        if isEditing || error != nil {
            Section(header: Text("Info")) {
                HStack {
                    TextField("Budget Name", text: $name)
                        .disabled(!isEditing)

                    BudgetIconPicker(selection: $icon, label: "Icon")
                        .disabled(!isEditing)
                }

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
    static let year = 2022
    static let storageProvider = MockStorageProvider(overviewYear: year)
    static var previews: some View {
        NavigationView {
            BudgetView(budget: Mocks.budgets(withYear: year)[0], storageProvider: storageProvider)
        }
    }
}
