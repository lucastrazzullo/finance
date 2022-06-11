//
//  BudgetOverviewItem.swift
//  Finance
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import SwiftUI

struct BudgetOverviewItem: View {

    let overview: BudgetOverview

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: overview.icon.rawValue).symbolRenderingMode(.hierarchical)
                    Text(overview.name).font(.headline)
                }

                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        switch overview.kind {
                        case .income:
                            Text("Expected").font(.caption2)
                        case .expense:
                            Text("Budget").font(.caption2)
                        }
                        AmountView(amount: overview.thresholdAmount).font(.caption2.bold())
                    }

                    HStack(spacing: 2) {
                        switch overview.kind {
                        case .income:
                            Text( "Incomes").font(.caption2)
                        case .expense:
                            Text( "Expenses").font(.caption2)
                        }
                        AmountView(amount: overview.amount).font(.caption2.bold())
                    }
                }
            }

            Spacer()

            HStack {
                VStack(alignment: .trailing) {
                    switch overview.kind {
                    case .income:
                        Text("Remaining").font(.caption2)
                    case .expense:
                        if overview.remainingAmount.value >= 0 {
                            Text("Remaining").font(.caption2)
                        } else {
                            Text("Negative").font(.caption2)
                        }
                    }
                    AmountView(amount: overview.remainingAmount).font(.subheadline)
                }

                ZStack(alignment: .leading) {
                    availabilityIndicatorView(
                        color: .gray.opacity(0.25),
                        percentage: 1.0)

                    availabilityIndicatorView(
                        color: availabilityIndicatorColor,
                        percentage: CGFloat(overview.amountPercentage))
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

    private var availabilityIndicatorColor: Color {
        switch abs(overview.amountPercentage) {
        case 0..<0.33:
            return .red
        case 0.33..<0.66:
            return .orange
        case 0.66...1.00:
            return .green
        case ..<0:
            return .gray.opacity(0.2)
        default:
            return .indigo
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
            ForEach(Mocks.allBudgets) { budget in
                BudgetOverviewItem(
                    overview: BudgetOverview(
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
