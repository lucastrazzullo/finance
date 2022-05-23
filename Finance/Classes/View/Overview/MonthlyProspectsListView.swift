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

    @State private var draggingOffset: CGFloat
    @State private var centredItemIdentifier: MonthlyProspect.ID

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
                        isHighlighted: prospect.id == centredItemIdentifier,
                        highestForecastedAvailability: highestForecastedAvailability,
                        highestTrendingAvailability: highestTrendingAvailability,
                        highestCurrentAvailability: highestCurrentAvailability)
                    )
                    .frame(width: itemWidth)
                    .alignmentGuide(prospect.id == centredItemIdentifier ? .selectedItem : .center) {
                        dimensions in dimensions[HorizontalAlignment.center] + draggingOffset
                    }
                    .onTapGesture {
                        withAnimation { select(prospect: prospect) }
                    }
                }
            }
            .padding(.horizontal)
            .frame(alignment: Alignment(horizontal: .selectedItem, vertical: .center))
            .gesture(DragGesture()
                .onChanged { value in
                    draggingOffset = -value.translation.width

                    if let centralItemIndex = prospects.firstIndex(where: { $0.id == centredItemIdentifier }) {
                        let numberOfDraggedItems = Int(abs(draggingOffset) / itemWidth)

                        let temporaryCenterItemIndex = draggingOffset > 0 ? centralItemIndex + numberOfDraggedItems : centralItemIndex - numberOfDraggedItems
                        if temporaryCenterItemIndex >= 0, temporaryCenterItemIndex < prospects.count {
                            let temporaryCenterItem = prospects[temporaryCenterItemIndex]
                            selectedMonth = temporaryCenterItem.month
                        }
                    }
                }
                .onEnded { value in withAnimation {
                    let endOffset = -value.translation.width
                    if let centralItemIndex = prospects.firstIndex(where: { $0.id == centredItemIdentifier }) {
                        let numberOfDraggedItems = Int(abs(endOffset) / itemWidth)

                        let newCenterItemIndex = endOffset > 0 ? centralItemIndex + numberOfDraggedItems : centralItemIndex - numberOfDraggedItems
                        if newCenterItemIndex >= 0, newCenterItemIndex < prospects.count {
                            let newCenterItem = prospects[newCenterItemIndex]
                            select(prospect: newCenterItem)
                        }
                    }

                    draggingOffset = 0
                }}
            )
        }
        .frame(maxHeight: 200)
        .padding(.vertical)
        .background(.gray.opacity(0.1))
    }

    init(prospects: [MonthlyProspect], selectedMonth: Binding<Int>) {
        self.prospects = prospects
        self._selectedMonth = Binding(projectedValue: selectedMonth)

        self.draggingOffset = 0
        self.centredItemIdentifier = (prospects.first(where: { $0.month == selectedMonth.wrappedValue }) ?? prospects[0]).id
    }

    private func select(prospect: MonthlyProspect) {
        centredItemIdentifier = prospect.id
        selectedMonth = prospect.month
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

        var currentMonthIndicatorColor: Color {
            switch State(prospect: prospect) {
            case .current:
                return .primary
            case .prediction, .completed:
                return .primary.opacity(0)
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

            VStack {
                Circle()
                    .foregroundColor(viewModel.currentMonthIndicatorColor)
                    .frame(width: 4, height: 4)

                Text(viewModel.month)
                    .font(viewModel.monthFont)
                    .foregroundColor(.secondary)
            }
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
        .background(.ultraThinMaterial)
        .cornerRadius(3)
    }
}

struct MonthlyProspectsListView_Previews: PreviewProvider {
    static var previews: some View {
        MonthlyProspectsListView(prospects: [
            .init(month: 4),
            .init(month: 5),
            .init(month: 6)
        ], selectedMonth: .constant(5))
    }
}
