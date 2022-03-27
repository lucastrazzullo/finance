//
//  DashboardView.swift
//  Finance
//
//  Created by luca strazzullo on 16/11/21.
//

import SwiftUI

struct DashboardView<StorageProviderType: StorageProvider & ObservableObject>: View {

    @StateObject var storageProvider: StorageProviderType

    var body: some View {
        NavigationView {
            ReportView(report: Report.default(with: []), storageProvider: storageProvider)
                .navigationTitle("Finance")
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(storageProvider: MockStorageProvider())
    }
}
