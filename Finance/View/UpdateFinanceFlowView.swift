//
//  UpdateFinanceFlowView.swift
//  Finance
//
//  Created by Luca Strazzullo on 01/12/2021.
//

import SwiftUI

final class UpdateFinanceFlow {

    @Published var updatedTotalNet: MoneyValue? = nil
    @Published var transactions: [Transaction] = []

    private let initialTotalNet: MoneyValue

    init(initialTotalNet: MoneyValue) {
        self.initialTotalNet = initialTotalNet
    }
}

struct UpdateFinanceFlowView: View {

    var body: some View {
        NavigationView {

            UpdateTotalNetView() { _ in }
                .navigationTitle("Update Total Net")

            InsertTransactionsView() { _ in }
                .navigationTitle("Transactions")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .padding(12)
    }
}

// MARK: - Previews

struct UpdateFinanceFlow_Previews: PreviewProvider {
    static var previews: some View {
        UpdateFinanceFlowView()
    }
}
