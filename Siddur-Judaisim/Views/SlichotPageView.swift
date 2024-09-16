//
//  SlichotPageView.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 04/09/2024.
//

import SwiftUI

struct SlichotPageView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    
    var prayers: [Prayer]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(prayers) { prayer in
                        if let textContent = loadContent(fileName: prayer.name) {
                            Text(textContent.string)
    //                            .font(.custom("Guttman Drogolin-Bold", size: textSize))
                                .font(.custom("Guttman Drogolin", size: appSettings.textSize))
    //                            .font(.custom("Guttman Vilna-Bold", size: appSettings.textSize))
                                .padding()
                                .foregroundColor(CustomPalette.black.color)
//                                .multilineTextAlignment(.center)
                        } else {
                            Text("CONTENT_FAIL_LOADING")
                        }
                    }

                }
            }
            .padding(.top, 1)
            .environment(\.layoutDirection, .rightToLeft)
            .background {
                Image("pageBG")
            }
        }
        .navigationBarTitle(NSLocalizedString("SLICHOT_LOC", comment: ""), displayMode: .inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                textSizeAdjustmentMenu
            }
        }
    }
    
    private var textSizeAdjustmentMenu: some View {
        Menu {
            Stepper("\(NSLocalizedString("TEXT_SIZE_LOC_STRING", comment: "")): \(Int(appSettings.textSize))", value: $appSettings.textSize, step: 1)
            
            Button(action: { appSettings.textSize = 20.0 }) {
                Text(NSLocalizedString("RESET_TO_DEFAULT", comment:""))
            }
        } label: {
            Label("TEXT_SIZE_LOC_STRING", systemImage: "textformat.size")
        }
    }
}

#Preview {
    SlichotPageView(prayers: MockPray().slichot).environmentObject(AppSettings())
}
