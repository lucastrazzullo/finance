//
//  MonthlyBudgetOverviewItem.swift
//  Finance
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import SwiftUI

struct MonthlyBudgetOverviewItem: View {

    let overview: MonthlyBudgetOverview

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    switch overview.icon {
                    case .system(let name):
                        Image(systemName: name).symbolRenderingMode(.hierarchical)
                    case .none:
                        EmptyView()
                    }
                    Text(overview.name).font(.headline)
                }
                HStack(spacing: 2) {
                    Text("Starting amount").font(.caption2)
                    AmountView(amount: overview.startingAmount).font(.caption2.bold())
                }

                HStack(spacing: 2) {
                    Text("Expenses").font(.caption2)
                    AmountView(amount: overview.totalExpenses).font(.caption2.bold())
                }
            }
            Spacer()

            VStack(alignment: .trailing) {
                Text(remainingLabel).font(.caption2)
                AmountView(amount: overview.remainingAmount).font(.subheadline)

                ZStack(alignment: .trailing) {
                    Rectangle().foregroundColor(.gray.opacity(0.2))
                    Rectangle().foregroundColor(rectangleColor).frame(width: rectangleWidth)
                }
                .frame(width: rectangleContainerWidth, height: rectangleContainerHeight)
                .cornerRadius(rectangleContainerHeight/2)
            }
        }
        .padding(8)
        .background(backgroundColor)
        .cornerRadius(6)
    }

    private var backgroundColor: Color {
        if overview.remainingAmount.value >= 0 {
            return .clear
        } else {
            return Color.brown.opacity(0.2)
        }
    }

    private var remainingLabel: String {
        if overview.remainingAmount.value >= 0 {
            return "Remaining"
        } else {
            return "Negative"
        }
    }

    private var rectangleColor: Color {
        switch overview.remainingAmountPercentage {
        case 0..<0.33:
            return .red
        case 0.33..<0.66:
            return .orange
        default:
            return .green
        }
    }

    private var rectangleWidth: CGFloat {
        return max(0, rectangleContainerWidth * CGFloat(overview.remainingAmountPercentage))
    }

    private let rectangleContainerWidth: CGFloat = 80
    private let rectangleContainerHeight: CGFloat = 3
}

struct MonthlyBudgetOverviewItem_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyBudgetOverviewItem(
            overview: MonthlyBudgetOverview(
                name: "Test Overview",
                icon: .system(name: "leaf"),
                startingAmount: .value(1000),
                totalExpenses: .value(100)
            )
        )
    }
}
