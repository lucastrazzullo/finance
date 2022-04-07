//
//  OverviewView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct OverviewView: View {

    let mostViewedViewModels: [MonthlyBudgetOverviewItem.ViewModel] = [
        .init(
            iconSystemName: "face.dashed.fill",
            label: "Ilenia",
            budgetOverview: .init(
                startingAmount: .value(1200),
                totalExpenses: .value(300)
            )
        ),
        .init(
            iconSystemName: "fork.knife",
            label: "Groceries",
            budgetOverview: .init(
                startingAmount: .value(800),
                totalExpenses: .value(700)
            )
        ),
        .init(
            iconSystemName: "bolt.car",
            label: "Car",
            budgetOverview: .init(
                startingAmount: .value(800),
                totalExpenses: .value(1000)
            )
        ),
        .init(
            iconSystemName: "leaf",
            label: "Health",
            budgetOverview: .init(
                startingAmount: .value(1000),
                totalExpenses: .value(500)
            )
        ),
    ]

    var body: some View {
        List {
            Section(header: Text("most viewed this month")) {
                ForEach(mostViewedViewModels, id: \.self) { viewModel in
                    MonthlyBudgetOverviewItem(viewModel: viewModel)
                }

                NavigationLink(destination: EmptyView()) {
                    Text("View all")
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct MonthlyBudgetOverviewItem: View {

    struct ViewModel: Hashable {
        let iconSystemName: String
        let label: String
        let budgetOverview: MonthlyBudgetOverview
    }

    let viewModel: ViewModel

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: viewModel.iconSystemName)
                    Text(viewModel.label).font(.headline)
                }
                HStack(spacing: 2) {
                    Text("Starting amount").font(.caption2)
                    AmountView(amount: viewModel.budgetOverview.startingAmount).font(.caption2.bold())
                }
            }
            Spacer()

            VStack(alignment: .trailing) {
                Text(remainingLabel).font(.caption2)
                AmountView(amount: viewModel.budgetOverview.remainingAmount).font(.subheadline)

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
        .cornerRadius(3)
    }

    private var backgroundColor: Color {
        if viewModel.budgetOverview.remainingAmount.value > 0 {
            return .clear
        } else {
            return Color.brown.opacity(0.2)
        }
    }

    private var remainingLabel: String {
        if viewModel.budgetOverview.remainingAmount.value > 0 {
            return "Remaining"
        } else {
            return "Negative"
        }
    }

    private var rectangleColor: Color {
        switch viewModel.budgetOverview.remainingAmountPercentage {
        case 0..<0.33:
            return .red
        case 0.33..<0.66:
            return .orange
        default:
            return .green
        }
    }

    private var rectangleWidth: CGFloat {
        return max(0, rectangleContainerWidth * CGFloat(viewModel.budgetOverview.remainingAmountPercentage))
    }

    private let rectangleContainerWidth: CGFloat = 80
    private let rectangleContainerHeight: CGFloat = 3
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView()
    }
}
