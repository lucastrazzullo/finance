//
//  NewBudgetSliceScheduleView.swift
//  Finance
//
//  Created by Luca Strazzullo on 03/03/2022.
//

import SwiftUI

struct NewBudgetSliceScheduleView: View {

    @State private var newScheduleAmount: Decimal? = nil
    @State private var newScheduleMonth: Int = Calendar.current.component(.month, from: .now)
    @State private var submitError: DomainError?

    let onSubmit: (BudgetSlice.Schedule) throws -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Info")) {
                    AmountTextField(amountValue: $newScheduleAmount, title: "Amount")
                    MonthPickerView(month: $newScheduleMonth)
                        .pickerStyle(.wheel)
                }

                Section {
                    if let error = submitError {
                        InlineErrorView(error: error)
                    }

                    Button("Save", action: submit)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewSliceView.saveButton)
                }
            }
            .navigationTitle("New schedule")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Private helper methods

    private func submit() {
        let amount = MoneyValue.value(newScheduleAmount ?? 0)

        do {
            try onSubmit(BudgetSlice.Schedule(amount: amount, month: newScheduleMonth))
            submitError = nil
        } catch {
            submitError = error as? DomainError
        }
    }
}

// MARK: - Previews

struct NewBudgetSliceScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NewBudgetSliceScheduleView() { _ in }
    }
}
