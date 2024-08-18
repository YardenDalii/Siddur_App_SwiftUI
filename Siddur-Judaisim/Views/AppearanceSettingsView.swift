//
//  AppearanceSettingsView.swift
//  Siddur
//
//  Created by Yarden Dali on 28/03/2024.
//

import SwiftUI

struct AppearanceSettingsView: View {
    
    @AppStorage("appearanceSettingKey") private var appearance: String = "light"
    
    let appearanceOptions = ["light", "dark", "system"]
    
    @State private var selectedAppearanceOption: String?
    
    var body: some View {
        NavigationView {
            List(appearanceOptions, id: \.self) { option in
                HStack {
                    Text(NSLocalizedString(option.capitalized, comment: ""))
                    Spacer()
                    
                    if appearance == option {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                
                .contentShape(Rectangle())
                .onTapGesture {
                    self.selectedAppearanceOption = option
                    setAppearance(option)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.17) {
                        self.selectedAppearanceOption = nil // Resets the temporary visual feedback
                    }
                }
                .listRowBackground(self.selectedAppearanceOption == option ? Color.gray.opacity(0.3): nil)
            }
        }
        .navigationBarTitle("APPEARANCE_LOC_STRING", displayMode: .inline)
        
    }
    
    private func setAppearance(_ option: String) {
        appearance = option
        
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            
            switch option {
            case "light":
                windowScene.windows.first?.overrideUserInterfaceStyle = .light
            case "dark":
                windowScene.windows.first?.overrideUserInterfaceStyle = .dark
            default:
                windowScene.windows.first?.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
}


#Preview {
    AppearanceSettingsView()
}
