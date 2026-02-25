//
//  AppearanceSettingsView.swift
//  Siddur
//
//  Created by Yarden Dali on 28/03/2024.
//

import SwiftUI

struct AppearanceSettingsView: View {

    @EnvironmentObject var appSettings: AppSettings

    let appearanceOptions = ["light", "dark", "system"]

    @State private var selectedAppearanceOption: String?

    var body: some View {
        List(appearanceOptions, id: \.self) { option in
            Button {
                appSettings.appearanceSetting = option
            } label: {
                HStack {
                    Text(NSLocalizedString(option.capitalized, comment: ""))
                    Spacer()

                    if appSettings.appearanceSetting == option {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
            .foregroundStyle(.primary)
        }
        .background(ImageBackgroundView())
        .scrollContentBackground(.hidden)
        .navigationBarTitle("APPEARANCE_LOC_STRING", displayMode: .inline)
    }
}


#Preview {
    AppearanceSettingsView()
        .environmentObject(AppSettings())
}
