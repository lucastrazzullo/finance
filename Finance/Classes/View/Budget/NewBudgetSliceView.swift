//
//  NewBudgetSliceView.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

struct NewBudgetSliceView: View {

    typealias OnSubmitErrorHandler = (DomainError) -> Void

    enum ConfigurationType: String, CaseIterable {
        case monthly = "Monthly"
        case scheduled = "Scheduled"
    }

    let onSubmit: (BudgetSlice, OnSubmitErrorHandler) -> Void

    @State private var newBudgetSliceName: String = ""
    @State private var newBudgetSliceConfigurationType: ConfigurationType = .monthly
    @State private var newBudgetSliceMonthlyAmount: String = ""
    @State private var newBudgetSliceSchedules: [BudgetSlice.ScheduledAmount] = []
    @State private var newBudgetSlicePresentedError: DomainError?
    @State private var isInsertNewBudgetSliceSchedulePresented: Bool = false

    var body: some View {
        Form {
            Section(header: Text("New Budget Slice")) {
                TextField("Name", text: $newBudgetSliceName)
                    .accessibilityIdentifier(AccessibilityIdentifier.NewSliceView.nameInputField)
            }

            Section(header: Text("Amount")) {
                Picker("Repeats", selection: $newBudgetSliceConfigurationType) {
                    ForEach(ConfigurationType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical)

                switch newBudgetSliceConfigurationType {
                case .monthly:
                    AmountTextField(amountValue: $newBudgetSliceMonthlyAmount, title: "Monthly Amount", prompt: nil)
                        .padding(.horizontal)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewSliceView.amountInputField)
                case .scheduled:
                    List {
                        ForEach(newBudgetSliceSchedules, id: \.month.id) { schedule in
                            AmountListItem(label: schedule.month.name, amount: schedule.amount)
                                .padding(4)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        newBudgetSliceSchedules.removeAll(where: { $0.month.id == schedule.month.id })
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    Button(action: { isInsertNewBudgetSliceSchedulePresented = true }) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }

            Section {
                if let error = newBudgetSlicePresentedError {
                    InlineErrorView(error: error)
                }

                Button("Save") {
                    do {
                        switch newBudgetSliceConfigurationType {
                        case .monthly:
                            let slice = try BudgetSlice(id: .init(), name: newBudgetSliceName, monthlyAmount: newBudgetSliceMonthlyAmount)
                            onSubmit(slice) { error in
                                newBudgetSlicePresentedError = error
                            }
                        case .scheduled:
                            let slice = try BudgetSlice(id: .init(), name: newBudgetSliceName, configuration: .scheduled(schedules: newBudgetSliceSchedules))
                            onSubmit(slice) { error in
                                newBudgetSlicePresentedError = error
                            }
                        }
                    } catch {
                        newBudgetSlicePresentedError = error as? DomainError ?? .budgetSlice(error: .cannotCreateTheSlice(underlyingError: error))
                    }
                }
                .accessibilityIdentifier(AccessibilityIdentifier.NewSliceView.saveButton)
            }
        }
        .sheet(isPresented: $isInsertNewBudgetSliceSchedulePresented) {
            NewBudgetSliceScheduleView { newSchedule, onErrorHandler in
                do {
                    try BudgetSlice.canAdd(schedule: newSchedule, to: newBudgetSliceSchedules)
                    newBudgetSliceSchedules.append(newSchedule)
                    isInsertNewBudgetSliceSchedulePresented = false
                } catch {
                    onErrorHandler(error as? DomainError ?? .budgetSlice(error: .cannotAddSchedule(underlyingError: error)))
                }
            }
        }
    }
}

// MARK: - Previews

struct NewBudgetSliceView_Previews: PreviewProvider {
    static var previews: some View {
        NewBudgetSliceView { _, _ in }
    }
}
