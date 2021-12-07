//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView: View {

    enum Overviews: Int, Identifiable, CaseIterable {
        case predictions
        case current

        var id: Int {
            return self.rawValue
        }

        var title: String {
            switch self {
            case .predictions:
                return "Predictions 2022"
            case .current:
                return "Current 2022"
            }
        }

        var label: String {
            switch self {
            case .predictions:
                return "Predictions"
            case .current:
                return "Current"
            }
        }

        var icon: String {
            switch self {
            case .predictions:
                return "person.crop.circle.badge.moon"
            case .current:
                return "clock.circle.fill"
            }
        }
    }

    @State private var isNewEntrySheetPresented: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    ForEach(Overviews.allCases) { overview in
                        NavigationLink(destination: BudgetOverviewView(title: overview.title)) {
                            Text(overview.label)
                        }
                    }
                }
                .navigationTitle("Finance 2022")

                Button("New entry") { isNewEntrySheetPresented = true }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(.thinMaterial)
            }
        }
        .sheet(isPresented: $isNewEntrySheetPresented, content: {
            UpdateFinanceFlowView()
        })
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
