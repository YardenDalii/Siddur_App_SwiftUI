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
                  
                    IconNavLink(iconImage: "globe",
                                linkName: "APP_LANG_LOC",
                                iconColor: Color.blue,
                                destination: LanguageSettingsView())
                }

                
                Section(footer: Text("Find-Pasuk")) {
                    IconNavLink(iconImage: "quote.bubble.fill",
                                linkName: "PERSONAL_PASUK_LOC",
                                iconColor: Color.brown,
                                destination: PasukView(userPasuk: $appSettings.userPasuk))
                    .environmentObject(appSettings)
                    
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
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.gray, lineWidth: 0.5)
//                                .frame(width: 353,height: 44)
//                        )
//                        .listRowBackground(Color.clear)
                }
            }
            .background(
                Image("pageBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
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
        .background(
            Image("pageBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
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


