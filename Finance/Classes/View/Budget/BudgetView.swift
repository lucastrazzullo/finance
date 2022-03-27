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

    @State private var deleteSlicesError: DomainError?
    @State private var isInsertNewSlicePresented: Bool = false

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AmountView(amount: controller.budget.amount)
                .font(.headline)
                .padding(.horizontal)

            SlicesList(
                slices: controller.budget.slices,
                isEditing: isEditing,
                error: deleteSlicesError,
                onAdd: { isInsertNewSlicePresented = true },
                onDelete: deleteSlices(at:)
            )
        }
        .sheet(isPresented: $isInsertNewSlicePresented) {
            NewBudgetSliceView { newSlice in
                try await controller.add(slice: newSlice)
                isInsertNewSlicePresented = false
            }
        }
        .navigationTitle(controller.budget.name)
        .toolbar { EditButton() }
        .onAppear {
            Task {
                try? await controller.fetch()
            }
        }
    }

    // MARK: Object life cycle

    init(budget: Budget, storageProvider: StorageProvider) {
        self.controller = BudgetController(budget: budget, storageProvider: storageProvider)
    }

    // MARK: Private helper methods

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

private struct SlicesList: View {

    let slices: [BudgetSlice]
    let isEditing: Bool
    let error: DomainError?

    let onAdd: () -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        List {
            Section(header: Text("Slices")) {
                ForEach(slices, id: \.id) { slice in
                    BudgetSlicesListItem(slice: slice, totalAmount: slices.totalAmount)
                }
                .onDelete(perform: onDelete)

                if isEditing {
                    Label("Add", systemImage: "plus")
                        .onTapGesture(perform: onAdd)
                }

                if let error = error {
                    InlineErrorView(error: error)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
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
