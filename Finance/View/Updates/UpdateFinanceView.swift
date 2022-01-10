//
//  UpdateFinanceView.swift
//  Finance
//
//  Created by Luca Strazzullo on 01/12/2021.
//

import SwiftUI

final class UpdateFinanceController: ObservableObject {

    @Published var updatedTotalNet: MoneyValue
    @Published var transactions: [Transaction] = []

    var totalDifference: MoneyValue {
        return updatedTotalNet - initialTotalNet
    }

    private let initialTotalNet: MoneyValue

    init(initialTotalNet: MoneyValue) {
        self.initialTotalNet = initialTotalNet
        self.updatedTotalNet = initialTotalNet
    }
}

struct UpdateFinanceView: View {

    @StateObject var controller: UpdateFinanceController = UpdateFinanceController(initialTotalNet: .value(10000))

    var body: some View {
        NavigationView {

            HStack {
                NavigationLink(destination: UpdateTotalNetView().navigationTitle("Total Net")) {
                    AmountCollectionItem(
                        title: "Update Total Net",
                        caption: "Update",
                        amount: controller.updatedTotalNet,
                        color: controller.totalDifference.value == 0 ? .orange : .green
                    )
                }

                NavigationLink(destination: InsertTransactionsView().navigationTitle("Transactions")) {
                    AmountCollectionItem(
                        title: "New Transactions",
                        caption: "Update",
                        amount: controller.transactions.totalAmount,
                        color: controller.transactions.totalAmount == controller.updatedTotalNet ? .green : .gray
                    )
                }
            }
            .foregroundColor(Color(UIColor.label))
            .navigationTitle("Update Finances")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .padding(12)
    }
}

// MARK: - Previews

struct UpdateFinanceFlow_Previews: PreviewProvider {
    static var previews: some View {
        UpdateFinanceView()
    }
}
