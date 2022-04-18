//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    @Environment(\.editMode) private var editMode

    @State private var updatingBudgetName: String
    @State private var updatingBudgetIcon: SystemIcon
    @State private var updateBudgetInfoError: DomainError?

    @State private var isInsertNewSlicePresented: Bool = false
    @State private var deleteSlicesError: DomainError?

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    let budget: Budget
    let addSliceToBudget: (BudgetSlice, Budget.ID) async throws -> Void
    let deleteSlices: (Set<BudgetSlice.ID>, Budget.ID) async throws -> Void
    let updateNameAndIcon: (String, SystemIcon, Budget.ID) async throws -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack {
                AmountView(amount: budget.amount)
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)

            List {
                if isEditing {
                    InfoSection(saveAction: saveUpdates, name: $updatingBudgetName, icon: $updatingBudgetIcon) {
                        if let error = updateBudgetInfoError, isEditing {
                            InlineErrorView(error: error)
                        }
                    }
                }

                SlicesListSection(slices: budget.slices, onDelete: isEditing ? delete : nil) {
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
            NewBudgetSliceView(onSubmit: add(slice:))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(isEditing ? updatingBudgetName : budget.name)
                    Image(systemName: isEditing ? updatingBudgetIcon.rawValue : budget.icon.rawValue)
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(maxWidth: .infinity)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }

    // MARK: Object life cycle

    init(budget: Budget,
         addSliceToBudget: @escaping (BudgetSlice, Budget.ID) async throws -> Void,
         deleteSlices: @escaping (Set<BudgetSlice.ID>, Budget.ID) async throws -> Void,
         updateNameAndIcon: @escaping (String, SystemIcon, Budget.ID) async throws -> Void) {

        self.budget = budget
        self.addSliceToBudget = addSliceToBudget
        self.deleteSlices = deleteSlices
        self.updateNameAndIcon = updateNameAndIcon

        self._updatingBudgetName = State<String>(wrappedValue: budget.name)
        self._updatingBudgetIcon = State<SystemIcon>(wrappedValue: budget.icon)
    }

    // MARK: Private helper methods

    private func add(slice: BudgetSlice) async throws {
        try await addSliceToBudget(slice, budget.id)
        isInsertNewSlicePresented = false
    }

    private func delete(slicesAt offsets: IndexSet) async {
        do {
            let identifiers = budget.slices(at: offsets).map(\.id)
            let identifiersSet = Set(identifiers)
            try await deleteSlices(identifiersSet, budget.id)
            deleteSlicesError = nil
        } catch {
            deleteSlicesError = error as? DomainError
        }
    }

    private func saveUpdates() async {
        do {
            try await updateNameAndIcon(updatingBudgetName, updatingBudgetIcon, budget.id)
            updateBudgetInfoError = nil
        } catch {
            updateBudgetInfoError = error as? DomainError
        }
    }
}

private struct InfoSection<Footer: View>: View {

    let saveAction: () async -> Void

    @Binding var name: String
    @Binding var icon: SystemIcon

    @ViewBuilder var footer: () -> Footer

    var body: some View {
        Section(header: Text("Info")) {
            VStack(alignment: .leading) {
                HStack(spacing: 24) {
                    TextField("Budget Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SystemIconPicker(selection: $icon, label: "Icon")
                        .padding(4)
                        .background(.quaternary)
                        .cornerRadius(6)

                    Button(action: { Task { await saveAction() } }) {
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
    let onDelete: ((IndexSet) async -> Void)?

    @ViewBuilder var footer: () -> Footer

    var body: some View {
        Section(header: Text("Slices")) {
            ForEach(slices, id: \.id) { slice in
                BudgetSlicesListItem(slice: slice, totalBudgetAmount: slices.totalAmount)
            }
            .onDelete(perform: { indices in Task { await onDelete?(indices) }})

            footer()
        }
    }
}

// MARK: - Previews

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BudgetView(
                budget: Mocks.budgets[0],
                addSliceToBudget: { _, _ in },
                deleteSlices: { _, _ in },
                updateNameAndIcon: { _, _, _ in }
            )
        }
    }
}
