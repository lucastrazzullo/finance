//
//  BudgetViewModel.swift
//  Finance
//
//  Created by Luca Strazzullo on 08/04/2022.
//

import Foundation

protocol BudgetViewModel: ObservableObject {
    var name: String { get }
    var icon: Icon { get }
    var amount: MoneyValue { get }
    var slices: [BudgetSlice] { get }

    func fetch() async throws
    func update(budgetName name: String, systemIcon: SystemIcon) async throws
    func add(slice: BudgetSlice) async throws
    func delete(slicesAt indices: IndexSet) async throws
}

extension BudgetViewModel {

    var systemIcon: SystemIcon {
        switch icon {
        case .system(let systemIcon):
            return systemIcon
        case .none:
            return SystemIcon.default
        }
    }
}
