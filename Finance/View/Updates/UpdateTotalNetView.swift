//
//  UpdateTotalNetView.swift
//  Finance
//
//  Created by luca strazzullo on 24/11/21.
//

import SwiftUI

struct UpdateTotalNetView: View {

    @State private var newTotalValue: String = ""

    private let currentTotalValue: MoneyValue = .value(10000)

    private var difference: MoneyValue? {
        guard let newTotalValue = MoneyValue.string(newTotalValue) else {
            return nil
        }
        return newTotalValue - currentTotalValue
    }

    var body: some View {
        VStack {
            HStack {
                AmountCollectionItem(
                    title: "Current net",
                    caption: "as of Friday 12 Oct",
                    amount: currentTotalValue,
                    color: Color(UIColor.systemGroupedBackground)
                )

                AmountCollectionItem(
                    title: "Updated net",
                    caption: "Sat 22 Oct 2022",
                    amount: .string(newTotalValue),
                    color: Color(UIColor.systemGroupedBackground)
                )
            }

            AmountCollectionItem(
                title: "Difference",
                caption: nil,
                amount: difference,
                color: difference ?? .zero < .zero ? .yellow : .green
            )

            Spacer()

            InsertAmountField(
                amountValue: $newTotalValue,
                title: "Total Net",
                prompt: nil
            )

            ConfirmButton {
//                if let value = MoneyValue.string(newTotalValue) {
//
//                }
            }
        }
    }
}

// MARK: - Previews

struct UpdateBudgetTotalView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateTotalNetView()
            .padding()
    }
}
