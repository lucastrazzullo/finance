//
//  OverviewListView.swift
//  Finance
//
//  Created by Luca Strazzullo on 07/04/2022.
//

import SwiftUI

struct OverviewListView<ViewModel: OverviewListViewModel>: View {

    @ObservedObject var viewModel: ViewModel

    @State private var month: Int = Calendar.current.component(.month, from: .now)
    @State private var addNewTransactionIsPresented: Bool = false

    var body: some View {
        NavigationView {
            List {
                if viewModel.overviews(for: month).count > 0 {
                    Section(header: Text("All Overviews")) {
                        ForEach(viewModel.overviews(for: month), id: \.self) { overview in
                            MonthlyBudgetOverviewItem(overview: overview)
                                .listRowSeparator(.hidden)
                        }
                    }
                }

                if viewModel.overviewsWithLowestAvailability(for: month).count > 0 {
                    Section(header: Text("Lowest budgets this month")) {
                        ForEach(viewModel.overviewsWithLowestAvailability(for: month), id: \.self) { overview in
                            MonthlyBudgetOverviewItem(overview: overview)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    MonthPickerView(month: $month)
                        .pickerStyle(MenuPickerStyle())
                }

                ToolbarItem(placement: .principal) {
                    DefaultToolbar(
                        title: viewModel.title,
                        subtitle: viewModel.subtitle
                    )
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { addNewTransactionIsPresented = true }) {
                        Label("New transaction", systemImage: "plus")
                    }
                }
            })
            .onAppear(perform: { Task { try? await viewModel.fetch() }})
            .sheet(isPresented: $addNewTransactionIsPresented) {
                AddTransactionsView(budgets: viewModel.overview.budgets) { transactions in
                    Task {
                        try await viewModel.add(transactions: transactions)
                        addNewTransactionIsPresented = false
                    }
                }
            }
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewListView(viewModel: MockOverviewListViewModel(overview: Mocks.overview))
    }
}

final class MockOverviewListViewModel: OverviewListViewModel {

    private(set) var overview: YearlyBudgetOverview

    init(overview: YearlyBudgetOverview) {
        self.overview = overview
    }

    var title: String {
        overview.name
    }

    var subtitle: String {
        String(overview.year)
    }

    func fetch() async throws {
        overview = Mocks.overview
    }

    func add(transactions: [Transaction]) async throws {
        overview.append(transactions: transactions)
    }

    func overviews(for month: Int) -> [MonthlyBudgetOverview] {
        overview.monthlyOverviews(month: month)
    }
}
