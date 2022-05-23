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
                let highestForecastedAvailability: MoneyValue = prospects.reduce(.zero) {
                    max($0, $1.forecastedEndOfTheMonthAvailability)
                }

                let highestTrendingAvailability: MoneyValue = prospects.reduce(.zero) {
                    max($0, $1.trendingEndOfTheMonthAvailability)
                }

                let highestCurrentAvailability: MoneyValue = prospects.reduce(.zero) {
                    max($0, $1.currentAvailability)
                }

                ForEach(prospects, id: \.self) { prospect in
                    MonthlyProspectItem(viewModel: .init(
                        prospect: prospect,
                        isHighlighted: prospect.month == (draggingHighlightedMonth ?? selectedMonth),
                        highestForecastedAvailability: highestForecastedAvailability,
                        highestTrendingAvailability: highestTrendingAvailability,
                        highestCurrentAvailability: highestCurrentAvailability)
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

    enum State {
        case current
        case completed
        case prediction

        init(prospect: MonthlyProspect) {
            let currentMonth = Calendar.current.component(.month, from: .now)
            if prospect.month < currentMonth {
                self = .completed
            } else if prospect.month > currentMonth {
                self = .prediction
            } else {
                self = .current
            }
        }
    }

    struct ViewModel: Hashable {

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
            switch State(prospect: prospect) {
            case .current:
                return .secondary
            case .prediction, .completed:
                return .primary
            }
        }

        var barColor: Color {
            switch State(prospect: prospect) {
            case .current:
                return .orange
            case .completed:
                return .orange.opacity(0.3)
            case .prediction:
                return .gray.opacity(0.3)
            }
        }

        var barHeight: CGFloat {
            let percentage = prospect.forecastedEndOfTheMonthAvailability.value / highestValue.value
            return CGFloat(truncating: NSDecimalNumber(decimal: percentage)) * containerHeight
        }

        var indicatorValue: MoneyValue {
            switch State(prospect: prospect) {
            case .current, .completed:
                return prospect.currentAvailability - prospect.forecastedEndOfTheMonthAvailability
            case .prediction:
                return prospect.forecastedEndOfTheMonthAvailability
            }
        }

        var indicatorHeight: CGFloat {
            switch State(prospect: prospect) {
            case .current, .completed:
                let percentage = prospect.currentAvailability.value / highestValue.value
                return CGFloat(truncating: NSDecimalNumber(decimal: percentage)) * containerHeight
            case .prediction:
                let percentage = prospect.trendingEndOfTheMonthAvailability.value / highestValue.value
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

        init(prospect: MonthlyProspect,
             isHighlighted: Bool,
             highestForecastedAvailability: MoneyValue,
             highestTrendingAvailability: MoneyValue,
             highestCurrentAvailability: MoneyValue) {
            self.prospect = prospect
            self.isHighlighted = isHighlighted
            self.highestValue = max(highestForecastedAvailability, highestTrendingAvailability, highestCurrentAvailability)
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
            .init(month: 4),
            .init(month: 5),
            .init(month: 6)
        ])
    }
}
