//
//  NewBudgetSliceScheduleView.swift
//  Finance
//
//  Created by Luca Strazzullo on 03/03/2022.
//

import SwiftUI

struct NewBudgetSliceScheduleView: View {

    typealias OnSubmitErrorHandler = (DomainError) -> Void

    let onSubmit: (BudgetSlice.ScheduledAmount, @escaping OnSubmitErrorHandler) -> Void

    @State private var newScheduleAmount: String = ""
    @State private var newScheduleMonth: Month.ID = Months.default.all[0].id
    @State private var newSchedulePresentedError: DomainError?

    var body: some View {
        Form {
            Section(header: Text("New Slice Schedule")) {
                AmountTextField(amountValue: $newScheduleAmount, title: "Amount", prompt: nil)
                    .padding(.horizontal)

                Picker("Month", selection: $newScheduleMonth) {
                    ForEach(Months.default.all, id: \.id) { month in
                        Text(month.name)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }

            Section {
                if let error = newSchedulePresentedError {
                    InlineErrorView(error: error)
                }

                Button("Save") {
                    guard let amount = MoneyValue.string(newScheduleAmount) else {
                        newSchedulePresentedError = .budgetSlice(error: .amountNotValid)
                        return
                    }

                    guard let month = Months.default[newScheduleMonth] else {
                        newSchedulePresentedError = .budgetSlice(error: .scheduleMonthNotValid)
                        return
                    }

                    onSubmit(.init(amount: amount, month: month)) { error in
                        newSchedulePresentedError = error
                    }
                }
                .accessibilityIdentifier(AccessibilityIdentifier.NewSliceView.saveButton)
            }
        }
    }
}

// MARK: - Previews

struct NewBudgetSliceScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        NewBudgetSliceScheduleView() { _, _ in }
    }
}
