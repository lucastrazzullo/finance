//
//  BudgetSlicesListItem.swift
//  Finance
//
//  Created by Luca Strazzullo on 03/03/2022.
//

import SwiftUI

struct BudgetSlicesListItem: View {

    let slice: BudgetSlice
    let totalBudgetAmount: MoneyValue

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            LeadingView(label: slice.name, sliceAmount: slice.amount)
            Spacer()
            TrailingView(configuration: slice.configuration)
        }
        .padding(.vertical, 8)
    }
}

struct LeadingView: View {

    let label: String
    let sliceAmount: MoneyValue

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.headline)

            HStack {
                Text("Total")
                AmountView(amount: sliceAmount)
            }
            .font(.footnote)
        }
    }
}

struct TrailingView: View {

    let configuration: BudgetSlice.Configuration

    var body: some View {
        switch configuration {
        case .monthly(let amount):
            TrailingViewItem(label: "Every month",
                             iconSystemName: "arrow.counterclockwise",
                             amount: amount)

        case .scheduled(let schedules):
            VStack(alignment: .trailing, spacing: 12) {
                ForEach(schedules, id: \.month) { schedule in
                    TrailingViewItem(label: Calendar.current.standaloneMonthSymbols[schedule.month - 1],
                                     iconSystemName: "calendar",
                                     amount: schedule.amount)
                }
            }
        }
    }
}

struct TrailingViewItem: View {

    let label: String
    let iconSystemName: String
    let amount: MoneyValue

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            AmountView(amount: amount).font(.headline)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(label).font(.caption)
                Image(systemName: iconSystemName).font(.caption2)
            }
        }
    }
}

// MARK: - Previews

struct BudgetSlicesListItem_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section(header: Text("Slices")) {
                ForEach(Mocks.slices, id: \.id) { slice in
                    BudgetSlicesListItem(slice: slice, totalBudgetAmount: Mocks.slices.totalAmount)
                }
            }
        }
        .listStyle(InsetListStyle())
    }
}
