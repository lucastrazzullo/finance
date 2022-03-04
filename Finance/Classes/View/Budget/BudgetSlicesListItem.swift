//
//  BudgetSlicesListItem.swift
//  Finance
//
//  Created by Luca Strazzullo on 03/03/2022.
//

import SwiftUI

struct BudgetSlicesListItem: View {

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    let slice: BudgetSlice
    let totalAmount: MoneyValue

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(slice.name).font(.headline)

                HStack {
                    Text("Total")
                    AmountView(amount: slice.amount)

                    if let percentage = makePercentageStringFor(amount: slice.amount) {
                        Text(percentage)
                            .padding(2)
                            .background(.green)
                            .cornerRadius(4)
                    }
                }
                .font(.footnote)
            }

            Spacer()

            switch slice.configuration {
            case .montly(let amount):
                makeItemTrailingView(amount: amount,
                                     label: "Monthly",
                                     iconSystemName: "arrow.counterclockwise.circle.fill")

            case .scheduled(let schedules):
                VStack(alignment: .trailing, spacing: 8) {
                    ForEach(schedules, id: \.month.id) { schedule in
                        makeItemTrailingView(amount: schedule.amount,
                                             label: schedule.month.name,
                                             iconSystemName: "calendar.circle.fill")
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Private factory methods

    private func makePercentageStringFor(amount: MoneyValue) -> String? {
        let percentage = NSDecimalNumber(decimal: amount.value / totalAmount.value)
        return Self.formatter.string(from: percentage)
    }

    @ViewBuilder
    private func makeItemTrailingView(amount: MoneyValue, label: String, iconSystemName: String) -> some View {
        HStack {
            VStack(alignment: .trailing, spacing: 4) {
                AmountView(amount: amount)
                Text(label).font(.caption)
            }
            Image(systemName: iconSystemName).font(.title)
        }
    }
}

// MARK: - Previews

struct BudgetSlicesListItem_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section(header: Text("Slices")) {
                ForEach(Mocks.slices, id: \.id) { slice in
                    BudgetSlicesListItem(slice: slice, totalAmount: Mocks.slices.totalAmount)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}
