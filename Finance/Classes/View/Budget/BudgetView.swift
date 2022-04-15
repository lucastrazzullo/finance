//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView<ViewModel: BudgetViewModel>: View {

    @Environment(\.editMode) private var editMode

    @ObservedObject var viewModel: ViewModel

    @State private var updatingBudgetName: String
    @State private var updatingBudgetIcon: SystemIcon
    @State private var updateBudgetInfoError: DomainError?

    @State private var isInsertNewSlicePresented: Bool = false
    @State private var deleteSlicesError: DomainError?

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack {
                AmountView(amount: viewModel.amount)
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

                SlicesListSection(slices: viewModel.slices, onDelete: isEditing ? deleteSlices(at:) : nil) {
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
                try await viewModel.add(slice: newSlice)
                isInsertNewSlicePresented = false
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(isEditing ? updatingBudgetName : viewModel.name)
                    Image(systemName: isEditing ? updatingBudgetIcon.rawValue : viewModel.systemIcon.rawValue)
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(maxWidth: .infinity)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .onAppear(perform: { Task { try? await viewModel.fetch() }})
    }

    // MARK: Object life cycle

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self._updatingBudgetName = State<String>(wrappedValue: viewModel.name)
        self._updatingBudgetIcon = State<SystemIcon>(wrappedValue: viewModel.systemIcon)
    }

    // MARK: Private helper methods

    private func saveUpdatedValues() {
        Task {
            do {
                try await viewModel.update(budgetName: updatingBudgetName, systemIcon: updatingBudgetIcon)
                updateBudgetInfoError = nil
            } catch {
                updateBudgetInfoError = error as? DomainError
            }
        }
    }

    private func deleteSlices(at indices: IndexSet) {
        Task {
            do {
                try await viewModel.delete(slicesAt: indices)
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
            BudgetView(viewModel: MockBudgetViewModel())
        }
    }
}

final class MockBudgetViewModel: BudgetViewModel {
    var name: String = "Car"
    var icon: Icon = .system(icon: .car)
    var slices: [BudgetSlice] = Mocks.houseSlices

    var amount: MoneyValue {
        slices.totalAmount
    }

    func fetch() async throws {
    }

    func update(budgetName name: String, systemIcon: SystemIcon) async throws {
        self.name = name
        self.icon = .system(icon: systemIcon)
    }

    func add(slice: BudgetSlice) async throws {
        let budget = try Budget(year: 2000, name: name, icon: icon, slices: slices)
        try budget.willAdd(slice: slice)
        slices.append(slice)
    }

    func delete(slicesAt indices: IndexSet) async throws {
        let budget = try Budget(year: 2000, name: name, icon: icon, slices: slices)
        try budget.willDelete(slicesWith: budget.sliceIdentifiers(at: indices))
        slices.remove(atOffsets: indices)
    }
}
