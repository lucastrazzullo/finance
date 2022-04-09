//
//  NewBudgetSliceScheduleView.swift
//  Finance
//
//  Created by Luca Strazzullo on 03/03/2022.
//

import SwiftUI

struct NewBudgetSliceScheduleView: View {

    @State private var newScheduleAmount: String = ""
    @State private var newScheduleMonth: Int = Calendar.current.component(.month, from: .now)
    @State private var submitError: DomainError?

    let onSubmit: (BudgetSlice.Schedule) throws -> Void

    var body: some View {
        Form {
            Section(header: Text("New Slice Schedule")) {
                AmountTextField(amountValue: $newScheduleAmount, title: "Amount", prompt: nil)
                MonthPickerView(month: $newScheduleMonth)
                    .pickerStyle(WheelPickerStyle())
            }

            Section {
                if let error = submitError {
                    InlineErrorView(error: error)
                }

                Button("Save", action: submit)
                    .accessibilityIdentifier(AccessibilityIdentifier.NewSliceView.saveButton)
            }
        }
    }

    // MARK: Private helper methods

    private func submit() {
        guard let amount = MoneyValue.string(newScheduleAmount) else {
            submitError = .budgetSlice(error: .amountNotValid)
            return
        }

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
