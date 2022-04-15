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
                    Image(systemName: isEditing ? updatingBudgetIcon : viewModel.iconSystemName)
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
        self._updatingBudgetIcon = State<String>(wrappedValue: viewModel.iconSystemName)
    }

    // MARK: Private helper methods

    private func saveUpdatedValues() {
        Task {
            do {
                try await viewModel.update(budgetName: updatingBudgetName, iconSystemName: updatingBudgetIcon)
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
            BudgetView(viewModel: MockBudgetViewModel())
        }
    }
}

final class MockBudgetViewModel: BudgetViewModel {
    var name: String = "Budget name"
    var iconSystemName: String = SystemIcon.car.rawValue
    var slices: [BudgetSlice] = Mocks.slices

    var amount: MoneyValue {
        slices.totalAmount
    }

    func fetch() async throws {
    }

    func update(budgetName name: String, iconSystemName: String) async throws {
        self.name = name
        self.iconSystemName = iconSystemName
    }

    func add(slice: BudgetSlice) async throws {
        let budget = try Budget(year: 2000, name: name, icon: .system(name: iconSystemName), slices: slices)
        try budget.willAdd(slice: slice)
        slices.append(slice)
    }

    func delete(slicesAt indices: IndexSet) async throws {
        let budget = try Budget(year: 2000, name: name, icon: .system(name: iconSystemName), slices: slices)
        try budget.willDelete(slicesWith: budget.sliceIdentifiers(at: indices))
        slices.remove(atOffsets: indices)
    }
}
