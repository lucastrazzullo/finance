//
//  MonthPickerView.swift
//  Finance
//
//  Created by Luca Strazzullo on 26/03/2022.
//

import SwiftUI

struct MonthPickerView: View {

    @Binding var month: Month.ID

    var body: some View {
        Picker("Month", selection: $month) {
            ForEach(Months.default.all, id: \.id) { month in
                Text(month.name)
            }
        }
    }
}

struct MonthPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MonthPickerView(month: .constant(Months.default.current.id))
    }
}
