//
//  MonthlyOverviewItem.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/06/2022.
//

import SwiftUI

struct MonthlyOverviewItem: View {

    struct ViewModel {

        var month: String {
            return Calendar.current.shortMonthSymbols[overview.month - 1]
        }

        var monthFont: Font {
            if isHighlighted {
                return .caption.bold()
            } else {
                return .caption
            }
        }

        var monthColor: Color {
            switch overview.effectiveBalance {
            case .current:
                return .secondary
            default:
                return .primary
            }
        }

        var barColor: Color {
            switch overview.effectiveBalance {
            case .current:
                return .orange
            case .closed:
                return .orange.opacity(0.3)
            case .future:
                return .gray.opacity(0.3)
            }
        }

        var barHeight: CGFloat {
            let percentage = overview.forecastedEndOfMonthBalance.value / highestValue.value
            return CGFloat(truncating: NSDecimalNumber(decimal: percentage)) * containerHeight
        }

        var indicatorValue: MoneyValue {
            switch overview.effectiveBalance {
            case .current(let actualAmount):
                return actualAmount - overview.forecastedEndOfMonthBalance
            case .closed(let closingAmount):
                return closingAmount - overview.forecastedEndOfMonthBalance
            case .future(let trendingAmount):
                return trendingAmount
            }
        }

        var indicatorHeight: CGFloat {
            switch overview.effectiveBalance {
            case .current(let actualAmount):
                let percentage = actualAmount.value / highestValue.value
                return CGFloat(truncating: NSDecimalNumber(decimal: percentage)) * containerHeight
            case .closed(let closingAmount):
                let percentage = closingAmount.value / highestValue.value
                return CGFloat(truncating: NSDecimalNumber(decimal: percentage)) * containerHeight
            case .future(let trendingAmount):
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

        private let overview: MonthlyOverview
        private let isHighlighted: Bool
        private let highestValue: MoneyValue

        init(overview: MonthlyOverview, isHighlighted: Bool, highestValue: MoneyValue) {
            self.overview = overview
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

struct MonthlyOverviewItem_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyOverviewItem(viewModel: .init(overview: Mocks.yearlyOverview.monthlyOverviews()[0], isHighlighted: false, highestValue: .value(1000)))
    }
}
