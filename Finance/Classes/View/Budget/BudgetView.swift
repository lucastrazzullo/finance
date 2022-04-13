//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    @Environment(\.editMode) private var editMode

    @ObservedObject var controller: BudgetController

    @State private var updatingBudgetName: String
    @State private var updatingBudgetIcon: String
    @State private var updateBudgetInfoError: DomainError?

    @State private var isInsertNewSlicePresented: Bool = false
    @State private var deleteSlicesError: DomainError?

    private let viewModel: BudgetViewModel

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
                if isEditing {
                    InfoSection(saveAction: saveUpdatedValues, name: $updatingBudgetName, icon: $updatingBudgetIcon) {
                        if let error = updateBudgetInfoError, isEditing {
                            InlineErrorView(error: error)
                        }
                    }
                }

                SlicesListSection(slices: controller.budget.slices,onDelete: isEditing ? deleteSlices(at:) : nil) {
                    if isEditing {
                        VStack {
                            Label("Add", systemImage: "plus")
                                .onTapGesture(perform: { isInsertNewSlicePresented = true })

                            if let error = deleteSlicesError {
                                InlineErrorView(error: error)
                            }
                        }
                    }
                }
            }
            .listStyle(.inset)
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
                .frame(maxWidth: .infinity)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .onAppear { fetch() }
    }

    // MARK: Object life cycle

    init(budget: Budget, storageProvider: StorageProvider) {
        self.controller = BudgetController(budget: budget, storageProvider: storageProvider)
        self.viewModel = BudgetViewModel(budget: budget)
        self._updatingBudgetName = State<String>(wrappedValue: viewModel.name)
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

private struct InfoSection<Footer: View>: View {

    let saveAction: () -> Void

    @Binding var name: String
    @Binding var icon: String

    @ViewBuilder var footer: () -> Footer

    var body: some View {
        Section(header: Text("Info")) {
            VStack(alignment: .leading) {
                HStack(spacing: 24) {
                    TextField("Budget Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    BudgetIconPicker(selection: $icon, label: "Icon")
                        .padding(4)
                        .background(.quaternary)
                        .cornerRadius(6)

                    Button(action: saveAction) {
                        Text("Save")
                    }
                    .buttonStyle(BorderedButtonStyle())
                }

                footer()
            }
        }
        .listRowSeparator(.hidden)
    }
}

private struct SlicesListSection<Footer: View>: View {

    let slices: [BudgetSlice]
    let onDelete: ((IndexSet) -> Void)?

    @ViewBuilder var footer: () -> Footer

    var body: some View {
        Section(header: Text("Slices")) {
            ForEach(slices, id: \.id) { slice in
                BudgetSlicesListItem(slice: slice, totalBudgetAmount: slices.totalAmount)
            }
            .onDelete(perform: onDelete)

            footer()
        }
    }
}

// MARK: - Previews

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BudgetView(budget: Mocks.budgets[0], storageProvider: try! MockStorageProvider())
        }
    }
}
