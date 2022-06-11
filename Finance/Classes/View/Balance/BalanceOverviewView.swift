//
//  BalanceOverviewView.swift
//  Finance
//
//  Created by Luca Strazzullo on 11/06/2022.
//

import SwiftUI

struct BalanceOverviewView: View {

    let currentBalance: MoneyValue

    var body: some View {
        HStack {
            Text("Balance")
            AmountView(amount: currentBalance)
            Spacer()
            Button(action: {}, label: { Image(systemName: "gear") })
        }
        .font(.headline)
        .tint(.primary)
        .padding()
        .background(
            Capsule(style: .circular)
                .foregroundColor(.yellow)
        )
        .padding(.top, 24)
        .padding(.horizontal)
    }
}

struct BalanceOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        BalanceOverviewView(currentBalance: .value(1000))
    }
}
