//
//  BudgetView.swift
//  Finance
//
//  Created by luca strazzullo on 18/11/21.
//

import SwiftUI

struct BudgetView: View {

    @Environment(\.editMode) private var editMode

    @ObservedObject var viewModel: BudgetViewModel

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
                    InfoSection(saveAction: viewModel.saveUpdates, name: $viewModel.updatingBudgetName, icon: $viewModel.updatingBudgetIcon) {
                        if let error = viewModel.updateBudgetInfoError, isEditing {
                            InlineErrorView(error: error)
                        }
                    }
                }

                SlicesListSection(slices: viewModel.slices,
                                  onDelete: isEditing
                                    ? { offsets in Task { await viewModel.delete(slicesAt: offsets) }}
                                    : nil) {
                    if isEditing {
                        VStack {
                            Label("Add", systemImage: "plus")
                                .onTapGesture(perform: { viewModel.isInsertNewSlicePresented = true })

                            if let error = viewModel.deleteSlicesError {
                                InlineErrorView(error: error)
                            }
                        }
                    }
                }
            }
            .listStyle(.inset)
        }
        .sheet(isPresented: $viewModel.isInsertNewSlicePresented) {
            NewBudgetSliceView(onSubmit: viewModel.add(slice:))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(isEditing ? viewModel.updatingBudgetName : viewModel.name)
                    Image(systemName: isEditing ? viewModel.updatingBudgetIcon.rawValue : viewModel.systemIconName)
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(maxWidth: .infinity)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
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
            BudgetView(viewModel: BudgetViewModel(budget: Mocks.budgets[0], handler: nil))
        }
    }
}
