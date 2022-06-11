//
//  MonthlyOverviewsListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 23/05/2022.
//

import SwiftUI

extension HorizontalAlignment {

    struct SelectedItemAlignment: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[HorizontalAlignment.center]
        }
    }

    static let selectedItem = HorizontalAlignment(SelectedItemAlignment.self)
}

struct MonthlyOverviewsListView: View {

    private let itemWidth: CGFloat = 90

    @State private var draggingOffset: CGFloat?
    @State private var draggingHighlightedMonth: Int?

    @Binding var selectedMonth: Int

    let overviews: [MonthlyOverview]

    var body: some View {
        ZStack {
            HStack(alignment: .bottom) {
                let highestValue: MoneyValue = overviews.reduce(.zero) { highestAmount, overview in
                    switch overview.effectiveBalance {
                    case .closed(let closingAmount):
                        return max(highestAmount, max(overview.forecastedEndOfMonthBalance, closingAmount))
                    case .current(let actualAmount):
                        return max(highestAmount, max(overview.forecastedEndOfMonthBalance, actualAmount))
                    case .future(let trendingAmount):
                        return max(highestAmount, max(overview.forecastedEndOfMonthBalance, trendingAmount))
                    }
                }

                ForEach(overviews) { overview in
                    MonthlyOverviewItem(viewModel: .init(
                        overview: overview,
                        isHighlighted: overview.month == (draggingHighlightedMonth ?? selectedMonth),
                        highestValue: highestValue)
                    )
                    .frame(width: itemWidth)
                    .alignmentGuide(overview.month == selectedMonth ? .selectedItem : .center) {
                        dimensions in dimensions[HorizontalAlignment.center] + (draggingOffset ?? 0)
                    }
                    .onTapGesture {
                        withAnimation { selectedMonth = overview.month }
                    }
                }
            }
            .frame(alignment: Alignment(horizontal: .selectedItem, vertical: .center))
            .gesture(DragGesture()
                .onChanged { value in 
                    let offset = -value.translation.width
                    draggingHighlightedMonth = centralItemMonth(offset: offset)
                    draggingOffset = offset
                }
                .onEnded { value in withAnimation {
                    let offset = -value.translation.width
                    draggingHighlightedMonth = nil
                    draggingOffset = nil
                    selectedMonth = centralItemMonth(offset: offset) ?? selectedMonth
                }}
            )
        }
        .frame(maxHeight: 200)
        .padding(.vertical)
        .background(.gray.opacity(0.1))
    }

    private func centralItemMonth(offset: CGFloat) -> Int? {
        guard let startingCentralItemIndex = overviews.firstIndex(where: { $0.id == selectedMonth }) else {
            return nil
        }

        let numberOfDraggedItems = Int(abs(offset) / itemWidth)
        let offsetCentralItemIndex = offset > 0
            ? startingCentralItemIndex + numberOfDraggedItems
            : startingCentralItemIndex - numberOfDraggedItems

        if offset > 0, offsetCentralItemIndex >= overviews.count {
            return overviews.last?.month
        }
        if offset < 0, offsetCentralItemIndex < 0 {
            return overviews.first?.month
        }

        return overviews[offsetCentralItemIndex].month
    }
}

struct MonthlyOverviewsListView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyOverviewsListView(
            selectedMonth: .constant(5),
            overviews: [
                .init(month: 4, openingBalance: .value(100), transactions: Mocks.allTransactions, budgets: Mocks.allBudgets),
                .init(month: 5, openingBalance: .value(100), transactions: Mocks.allTransactions, budgets: Mocks.allBudgets),
                .init(month: 6, openingBalance: .value(100), transactions: Mocks.allTransactions, budgets: Mocks.allBudgets)
            ]
        )
    }
}
