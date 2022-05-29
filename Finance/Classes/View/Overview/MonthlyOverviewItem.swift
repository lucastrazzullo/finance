//
//  MonthlyOverviewItem.swift
//  Finance
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import SwiftUI

struct MonthlyOverviewItem: View {

    let overview: MonthlyBudgetOverview

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: overview.icon.rawValue).symbolRenderingMode(.hierarchical)
                    Text(overview.name).font(.headline)
                }

                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        Text("Budget").font(.caption2)
                        AmountView(amount: overview.startingAmount).font(.caption2.bold())
                    }

                    HStack(spacing: 2) {
                        switch overview.budget.kind {
                        case .income:
                            Text( "Incomes").font(.caption2)
                        case .expense:
                            Text( "Expenses").font(.caption2)
                        }
                        AmountView(amount: overview.transactionsInMonth.totalAmount).font(.caption2.bold())
                    }
                }
            }

            Spacer()

            HStack {
                VStack(alignment: .trailing) {
                    Text(availabilityLabel).font(.caption2)
                    AmountView(amount: overview.remainingAmount).font(.subheadline)
                }

                ZStack(alignment: .leading) {
                    availabilityIndicatorView(
                        color: .gray.opacity(0.25),
                        percentage: 1.0)

                    availabilityIndicatorView(
                        color: availabilityIndicatorColor,
                        percentage: CGFloat(overview.remainingAmountPercentage))
                }
            }
        }
        .padding(8)
        .background(backgroundColor)
        .cornerRadius(6)
    }

    private var backgroundColor: Color {
        if overview.remainingAmount.value > 0 {
            return .clear
        } else {
            return Color.brown.opacity(0.2)
        }
    }

    private var availabilityLabel: String {
        if overview.remainingAmount.value >= 0 {
            return "Remaining"
        } else {
            return "Negative"
        }
    }

    private var availabilityIndicatorColor: Color {
        switch overview.remainingAmountPercentage {
        case 0..<0.33:
            return .red
        case 0.33..<0.66:
            return .orange
        default:
            return .green
        }
    }

    @ViewBuilder private func availabilityIndicatorView(color: Color, percentage: CGFloat) -> some View {
        Circle()
            .trim(from: 0.0, to: percentage)
            .rotation(.degrees(-90))
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: 4,
                    lineCap: .round,
                    dashPhase: 10
                )
            )
           .frame(width: 30, height: 30)
    }
}

struct MonthlyBudgetOverviewItem_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ForEach(Mocks.expenseBudgets) { budget in
                MonthlyOverviewItem(
                    overview: MonthlyBudgetOverview(
                        month: 1,
                        budget: budget,
                        transactions: Mocks.allTransactions
                    )
                )
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}
