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

    @State private var addNewTransactionError: DomainError?
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
                        title: viewModel.overviewTitle,
                        subtitle: viewModel.overviewSubtitle
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
                NewTransactionView(budgets: viewModel.overviewBudgets) { transaction in
                    Task {
                        do {
                            try await viewModel.add(transaction: transaction)
                            addNewTransactionIsPresented = false
                            addNewTransactionError = nil
                        } catch {
                            addNewTransactionError = error as? DomainError
                        }
                    }
                }
            }
        }
    }
}

struct OverviewView_Previews: PreviewProvider {
    let overview = Mocks.overview
    static var previews: some View {
        OverviewListView(viewModel: MockOverviewListViewModel())
    }
}

private final class MockOverviewListViewModel: OverviewListViewModel {

    private var overview: YearlyBudgetOverview?

    var overviewTitle: String {
        overview?.name ?? "No Overview"
    }
    var overviewSubtitle: String {
        String(overview?.year ?? 0)
    }
    var overviewBudgets: [Budget] {
        overview?.budgets ?? []
    }

    func fetch() async throws {
        overview = Mocks.overview
    }

    func add(transaction: Transaction) async throws {
        overview?.append(transaction: transaction)
    }

    func overviews(for month: Int) -> [MonthlyBudgetOverview] {
        overview?.monthlyOverviews(month: month) ?? []
    }
}
