//
//  NewBudgetSliceView.swift
//  Finance
//
//  Created by Luca Strazzullo on 25/01/2022.
//

import SwiftUI

struct NewBudgetSliceView: View {

    enum Schedule: String, CaseIterable {
        case monthly = "Monthly"
        case scheduled = "Scheduled"
    }

    // MARK: Properties

    @State private var sliceName: String = ""
    @State private var sliceConfigurationType: Schedule = .monthly
    @State private var sliceMonthlyAmount: Decimal? = nil

    @State private var sliceSchedules: [BudgetSlice.Schedule] = []
    @State private var isInsertNewSchedulePresented: Bool = false

    @State private var submitError: DomainError?

    let onSubmit: (BudgetSlice) async throws -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Info")) {
                    TextField("Name", text: $sliceName)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewSliceView.nameInputField)
                }

                Section(header: Text("Amount")) {
                    Picker("Schedule", selection: $sliceConfigurationType) {
                        ForEach(Schedule.allCases, id: \.self) { type in
                            Text(type.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical)

                    switch sliceConfigurationType {
                    case .monthly:
                        AmountTextField(amountValue: $sliceMonthlyAmount, title: "Monthly Amount")
                            .accessibilityIdentifier(AccessibilityIdentifier.NewSliceView.amountInputField)
                    case .scheduled:
                        SchedulesList(schedules: $sliceSchedules)
                        Button(action: { isInsertNewSchedulePresented = true }) {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }

                Section {
                    if let error = submitError {
                        InlineErrorView(error: error)
                    }

                    Button("Save", action: submit)
                        .accessibilityIdentifier(AccessibilityIdentifier.NewSliceView.saveButton)
                }
            }
            .sheet(isPresented: $isInsertNewSchedulePresented) {
                NewBudgetSliceScheduleView { newSchedule in
                    try BudgetSlice.willAdd(schedule: newSchedule, to: sliceSchedules)
                    sliceSchedules.append(newSchedule)
                    isInsertNewSchedulePresented = false
                }
            }
            .navigationTitle("New slice")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Private helper methods

    private func submit() {
        Task {
            do {
                let slice = try makeSlice()
                try await onSubmit(slice)
                submitError = nil
            } catch {
                submitError = error as? DomainError
            }
        }
    }

    private func makeSlice() throws -> BudgetSlice {
        switch sliceConfigurationType {
        case .monthly:
            return try BudgetSlice(name: sliceName, configuration: .monthly(amount: .value(sliceMonthlyAmount ?? 0)))
        case .scheduled:
            return try BudgetSlice(name: sliceName, configuration: .scheduled(schedules: sliceSchedules))
        }
    }
}

private struct SchedulesList: View {

    @Binding var schedules: [BudgetSlice.Schedule]

    var body: some View {
        List {
            ForEach(schedules, id: \.month) { schedule in
                let monthName = Calendar.current.standaloneMonthSymbols[schedule.month - 1]
                AmountListItem(label: monthName, amount: schedule.amount)
                    .padding(4)
            }
            .onDelete(perform: delete(at:))
        }
    }

    private func delete(at indices: IndexSet) {
        indices.forEach({ schedules.remove(at: $0) })
    }
}

// MARK: - Previews

struct NewBudgetSliceView_Previews: PreviewProvider {
    static var previews: some View {
        NewBudgetSliceView { _ in }
    }
}
