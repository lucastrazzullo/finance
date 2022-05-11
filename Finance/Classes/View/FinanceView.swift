//
//  FinanceView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct FinanceView: View {

    @Environment(\.storageProvider) private var storageProvider

    @ObservedObject var viewModel: FinanceViewModel

    var body: some View {
        TabView {
            NavigationView {
                VStack(alignment: .leading, spacing: 0) {
                    makeMonthlyProspectView()
                    makeMonthlyOverviewsListView()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: { makeToolbar(titlePrefix: "Overview", showsMonthPicker: true) })
            }
            .tabItem {
                Label("Overview", systemImage: "list.bullet.below.rectangle")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.overviewTab)
            }

            NavigationView {
                makeBudgetsListView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: { makeToolbar(titlePrefix: "Budgets", showsMonthPicker: false) })
            }
            .tabItem {
                Label("Budgets", systemImage: "aspectratio.fill")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.budgetsTab)
            }

            NavigationView {
                makeTransactionsListView(transactions: viewModel.yearlyOverview.expenses)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(content: { makeToolbar(titlePrefix: "Transactions", showsMonthPicker: false) })
            }
            .tabItem {
                Label("Transactions", systemImage: "arrow.left.arrow.right.square")
                    .accessibilityIdentifier(AccessibilityIdentifier.FinanceView.transactionsTab)
            }
        }
        .sheet(isPresented: $viewModel.isAddNewTransactionPresented) {
            AddTransactionsView(
                budgets: viewModel.yearlyOverview.budgets,
                onSubmit: viewModel.add(transactions:)
            )
        }
        .sheet(isPresented: $viewModel.isAddNewBudgetPresented) {
            NewBudgetView(
                year: viewModel.yearlyOverview.year,
                onSubmit: viewModel.add(budget:)
            )
        }
        .task {
            try? await viewModel.load()
        }
        .refreshable {
            try? await viewModel.load()
        }
    }

    // MARK: Private builder methods - Tabs

    @ViewBuilder private func makeMonthlyProspectView() -> some View {
        MonthlyProspectView(
            selectedMonth: $viewModel.selectedMonth,
            prospects: viewModel.monthlyProspects
        )
    }

    @ViewBuilder private func makeMonthlyOverviewsListView() -> some View {
        MontlyOverviewsListView(
            monthlyOverviews: viewModel.monthlyOverviews,
            monthlyOverviewsWithLowestAvailability: viewModel.monthlyOverviewsWithLowestAvailability,
            item: { monthlyOverview in
                NavigationLink(
                    destination: {
                        TransactionsListView(
                            viewModel: TransactionsListViewModel(
                                transactions: monthlyOverview.expensesInMonth,
                                addTransactions: { self.viewModel.isAddNewTransactionPresented = true },
                                deleteTransactions: viewModel.delete(transactionsWith:)
                            )
                        )
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar(content: { makeToolbar(titlePrefix: "Expenses", showsMonthPicker: true) })
                    },
                    label: {
                        MonthlyOverviewItem(overview: monthlyOverview)
                    }
                )
            }
        )
    }

    @ViewBuilder private func makeBudgetsListView() -> some View {
        BudgetsListView(
            viewModel: BudgetsListViewModel(
                budgets: viewModel.yearlyOverview.budgets,
                addBudgets: { self.viewModel.isAddNewBudgetPresented = true },
                deleteBudgets: viewModel.delete(budgetsWith:)
            ),
            item: { budget in
                NavigationLink(
                    destination: BudgetView(
                        viewModel: BudgetViewModel(budget: budget, storageHandler: viewModel)
                    ),
                    label: {
                        BudgetsListItem(budget: budget)
                    }
                )
            }
        )
    }

    @ViewBuilder private func makeTransactionsListView(transactions: [Transaction]) -> some View {
        TransactionsListView(
            viewModel: TransactionsListViewModel(
                transactions: transactions,
                addTransactions: { self.viewModel.isAddNewTransactionPresented = true },
                deleteTransactions: viewModel.delete(transactionsWith:)
            )
        )
    }

    // MARK: Private builder methods - Toolbar

    @ToolbarContentBuilder private func makeToolbar(titlePrefix: String, showsMonthPicker: Bool) -> some ToolbarContent {

        ToolbarItem(placement: .principal) {
            let title = "\(titlePrefix) \(viewModel.yearlyOverview.name)"
            let year = String(viewModel.yearlyOverview.year)

            VStack {
                Text(title).font(.title2.bold())

                HStack(spacing: 6) {
                    Text(year).font(.caption)

                    if showsMonthPicker {
                        Text("›")
                        Text(viewModel.month).font(.caption.bold())
                    }
                }
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                if showsMonthPicker {
                    MonthPickerView(month: $viewModel.selectedMonth)
                        .pickerStyle(MenuPickerStyle())
                }

                Button(action: { viewModel.isAddNewTransactionPresented = true }) {
                    Label("New transaction", systemImage: "plus")
                }

                Button(action: { self.viewModel.isAddNewBudgetPresented = true }) {
                    Label("New budget", systemImage: "plus")
                }
            }
            label: {
                Label("Options", systemImage: "ellipsis.circle")
            }
        }
    }
}

private struct MonthlyProspectView: View {

    @Binding var selectedMonth: Int

    let prospects: [MonthlyProspect]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
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
                        highestForecastedAvailability: highestForecastedAvailability,
                        highestTrendingAvailability: highestTrendingAvailability,
                        highestCurrentAvailability: highestCurrentAvailability)
                    )
                }
            }
        }
        .frame(height: 140)
        .padding()
        .background(.gray.opacity(0.1))
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
            switch State(prospect: prospect) {
            case .current:
                return .subheadline
            case .prediction, .completed:
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

        private let prospect: MonthlyProspect
        private let highestValue: MoneyValue

        init(prospect: MonthlyProspect,
             highestForecastedAvailability: MoneyValue,
             highestTrendingAvailability: MoneyValue,
             highestCurrentAvailability: MoneyValue) {
            self.prospect = prospect
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
                    .frame(width: 90, height: viewModel.barHeight)
                    .cornerRadius(3)

                VStack(spacing: 2) {
                    Rectangle()
                        .foregroundColor(.primary)
                        .frame(width: 80, height: 3)
                        .cornerRadius(3)
                        .padding(.bottom, 0)

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

// MARK: - Previews

struct FinanceView_Previews: PreviewProvider {
    static let storageProvider = MockStorageProvider(budgets: Mocks.budgets, transactions: Mocks.transactions)
    static var previews: some View {
        FinanceView(viewModel: .init(year: Mocks.year, storageProvider: storageProvider))
//            .preferredColorScheme(.dark)
            .environment(\.storageProvider, storageProvider)
    }
}