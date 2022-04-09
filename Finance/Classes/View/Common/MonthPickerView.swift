//
//  MonthPickerView.swift
//  Finance
//
//  Created by Luca Strazzullo on 26/03/2022.
//

import SwiftUI

struct MonthPickerView: View {

    @Binding var month: Int

    var body: some View {
        Picker("Month", selection: $month) {
            ForEach(1...Calendar.current.standaloneMonthSymbols.count, id: \.self) { index in
                Text(Calendar.current.standaloneMonthSymbols[index - 1])
            }
        }
    }
}

struct MonthPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MonthPickerView(month: .constant(Calendar.current.component(.month, from: .now)))
    }
}
