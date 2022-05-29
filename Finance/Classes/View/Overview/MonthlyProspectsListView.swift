//
//  MonthlyProspectsListView.swift
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

struct MonthlyProspectsListView: View {

    private let itemWidth: CGFloat = 90

    @State private var draggingOffset: CGFloat?
    @State private var draggingHighlightedMonth: Int?

    @Binding var selectedMonth: Int

    let prospects: [MonthlyProspect]

    var body: some View {
        ZStack {
            HStack(alignment: .bottom) {
                let highestValue: MoneyValue = prospects.reduce(.zero) { highestAmount, prospect in
                    switch prospect.state {
                    case .closed(let forecastedAmount, let closingAmount):
                        return max(highestAmount, max(forecastedAmount, closingAmount))
                    case .current(let forecastedAmount, let actualAmount):
                        return max(highestAmount, max(forecastedAmount, actualAmount))
                    case .future(let forecastedAmount, let trendingAmount):
                        return max(highestAmount, max(forecastedAmount, trendingAmount))
                    }
                }

                ForEach(prospects) { prospect in
                    MonthlyProspectItem(viewModel: .init(
                        prospect: prospect,
                        isHighlighted: prospect.month == (draggingHighlightedMonth ?? selectedMonth),
                        highestValue: highestValue)
                    )
                    .frame(width: itemWidth)
                    .alignmentGuide(prospect.month == selectedMonth ? .selectedItem : .center) {
                        dimensions in dimensions[HorizontalAlignment.center] + (draggingOffset ?? 0)
                    }
                    .onTapGesture {
                        withAnimation { selectedMonth = prospect.month }
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
        guard let startingCentralItemIndex = prospects.firstIndex(where: { $0.id == selectedMonth }) else {
            return nil
        }

        let numberOfDraggedItems = Int(abs(offset) / itemWidth)
        let offsetCentralItemIndex = offset > 0
            ? startingCentralItemIndex + numberOfDraggedItems
            : startingCentralItemIndex - numberOfDraggedItems

        if offset > 0, offsetCentralItemIndex >= prospects.count {
            return prospects.last?.month
        }
        if offset < 0, offsetCentralItemIndex < 0 {
            return prospects.first?.month
        }

        return prospects[offsetCentralItemIndex].month
    }
}

private struct MonthlyProspectItem: View {

    struct ViewModel {

        var month: String {
            return Calendar.current.shortMonthSymbols[prospect.month - 1]
        }

        var monthFont: Font {
            if isHighlighted {
                return .caption.bold()
            } else {
                return .caption
            }
        }

        var monthColor: Color {
            switch prospect.state {
            case .current:
                return .secondary
            default:
                return .primary
            }
        }

        var barColor: Color {
            switch prospect.state {
            case .current:
                return .orange
            case .closed:
                return .orange.opacity(0.3)
            case .future:
                return .gray.opacity(0.3)
            }
        }

        var barHeight: CGFloat {
            switch prospect.state {
            case .current(let forecastedAmount, _):
                let percentage = forecastedAmount.value / highestValue.value
                return CGFloat(truncating: NSDecimalNumber(decimal: percentage)) * containerHeight
            case .closed(let forecastedAmount, _):
                let percentage = forecastedAmount.value / highestValue.value
                return CGFloat(truncating: NSDecimalNumber(decimal: percentage)) * containerHeight
            case .future(let forecastedAmount, _):
                let percentage = forecastedAmount.value / highestValue.value
                return CGFloat(truncating: NSDecimalNumber(decimal: percentage)) * containerHeight
            }
        }

        var indicatorValue: MoneyValue {
            switch prospect.state {
            case .current(let forecastedAmount, let actualAmount):
                return actualAmount - forecastedAmount
            case .closed(let forecastedAmount, let closingAmount):
                return closingAmount - forecastedAmount
            case .future(_, let trendingAmount):
                return trendingAmount
            }
        }

        var indicatorHeight: CGFloat {
            switch prospect.state {
            case .current(_, let actualAmount):
                let percentage = actualAmount.value / highestValue.value
                return CGFloat(truncating: NSDecimalNumber(decimal: percentage)) * containerHeight
            case .closed(_, let closingAmount):
                let percentage = closingAmount.value / highestValue.value
                return CGFloat(truncating: NSDecimalNumber(decimal: percentage)) * containerHeight
            case .future(_, let trendingAmount):
                let percentage = trendingAmount.value / highestValue.value
                return CGFloat(truncating: NSDecimalNumber(decimal: percentage)) * containerHeight
            }
        }

        var containerHeight: CGFloat {
            return 100
        }

        var containerBackground: Material {
            switch isHighlighted {
            case true:
                return .ultraThinMaterial
            case false:
                return .thin
            }
        }

        private let prospect: MonthlyProspect
        private let isHighlighted: Bool
        private let highestValue: MoneyValue

        init(prospect: MonthlyProspect, isHighlighted: Bool, highestValue: MoneyValue) {
            self.prospect = prospect
            self.isHighlighted = isHighlighted
            self.highestValue = highestValue
        }
    }

    let viewModel: ViewModel

    var body: some View {
        VStack {

            Text(viewModel.month)
                .font(viewModel.monthFont)
                .foregroundColor(.secondary)
                .padding(.top)

            Spacer()

            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundColor(viewModel.barColor)
                    .frame(height: viewModel.barHeight)
                    .cornerRadius(3)

                VStack(spacing: 2) {
                    Rectangle()
                        .foregroundColor(.primary)
                        .frame(height: 3)
                        .cornerRadius(3)
                        .padding(.bottom, 0)
                        .padding(.horizontal, 4)

                    AmountView(amount: viewModel.indicatorValue)
                        .font(.footnote)

                    Spacer()
                }
                .frame(height: viewModel.indicatorHeight)
            }
            .frame(height: viewModel.containerHeight, alignment: .bottom)
        }
        .background(viewModel.containerBackground)
        .cornerRadius(3)
    }
}

struct MonthlyProspectsListView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyProspectsListView(
            selectedMonth: .constant(5),
            prospects: [
                .init(year: Mocks.year, month: 4, openingYearBalance: Mocks.openingYearBalance, transactions: Mocks.allTransactions, budgets: Mocks.allBudtets),
                .init(year: Mocks.year, month: 5, openingYearBalance: Mocks.openingYearBalance, transactions: Mocks.allTransactions, budgets: Mocks.allBudtets),
                .init(year: Mocks.year, month: 6, openingYearBalance: Mocks.openingYearBalance, transactions: Mocks.allTransactions, budgets: Mocks.allBudtets)
            ]
        )
    }
}
