//
//  SettingsView.swift
//  Siddur
//
//  Created by Yarden Dali on 28/03/2024.
//

import SwiftUI


struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        NavigationStack {
            List {
                
                Section(header: Text("SETTINGS_LOC_STRING")) {
                    IconNavLink(iconImage: "textformat.characters",
                                linkName: "FONT_SELECTION_LOC",
                                iconColor: .purple,
                                destination: FontSelectionView())
                    
                    IconNavLink(iconImage: "globe",
                                linkName: "APP_LANG_LOC",
                                iconColor: Color.blue,
                                destination: LanguageSettingsView())
                }
                
                Section(header: Text("PERSONAL_SETTINGS_LOC"), footer: Text("SMART_SIDDUR_DESC_LOC")) {
//                    HStack {
                        Toggle(isOn: $appSettings.smartSiddur) {
                            Text("SMART_SIDDUR_TOGGLE_LOC")
//                        }
                                .disabled(true)
                            
                    }
                }
                Section(footer: Text("FIND_PASUK_LOC")) {
                    IconNavLink(iconImage: "quote.bubble.fill",
                                linkName: "PERSONAL_PASUK_LOC",
                                iconColor: Color.brown,
                                destination: PasukView(userPasuk: $appSettings.userPasuk))

                    
                    if appSettings.userPasuk.isEmpty {
                        Text(NSLocalizedString("NO_PASUK_PROMPT", comment: ""))
                            .foregroundStyle(.gray)
                            .padding(.leading, 37)
                    } else {
                        Text(appSettings.userPasuk)
                            .foregroundStyle(.gray)
                            .padding(.leading, 37)
                    }
                }
                
                
                
                Section(header: Text("ABOUT_LOC_STRING")) {
                    IconNavLink(iconImage: "info.circle.fill",
                                linkName: "ABOUT_LOC_STRING",
                                iconColor: Color.green,
                                destination: AboutView())
                }
            }
            .background(ImageBackgroundView())
            .scrollContentBackground(.hidden)
            .navigationTitle("SETTINGS_LOC_STRING")
        }
    }
    
    
}



struct IconNavLink<Destination: View>: View {
    var iconImage: String
    var linkName: String
    var iconColor: Color
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 6).fill(iconColor)
                        .frame(width: 28, height: 28)
                    Image(systemName: iconImage).foregroundColor(.white)
                }
                Text(NSLocalizedString(linkName, comment: ""))
            }
        }
    }
}



struct PasukView: View {
    
    @Binding var userPasuk: String
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            TextField("ENTER_PASUK_PROMPT", text: $userPasuk, onEditingChanged: { editing in
                isEditing = editing
            })
            .focused($isFocused)
            .onSubmit {
                dismiss()
            }
            .onAppear {
                self.isFocused = true
            }
            .overlay(
                HStack {
                    Spacer()
                    if isEditing && !userPasuk.isEmpty {
                        Button(action: {
                            userPasuk = ""
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundColor(Color(UIColor.opaqueSeparator))
                        }
                        .frame(alignment: .trailing)
                    }
                }
            )
        }
        .background(ImageBackgroundView())
        .scrollContentBackground(.hidden)
        .navigationBarTitle("PERSONAL_PASUK_LOC", displayMode: .inline)
    }
}



struct LanguageSettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {}
        .onAppear {
            openAppSettings()
        }
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url)
        
        dismiss()
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}
