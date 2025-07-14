//
//  SettingsView.swift
//  Siddur
//
//  Created by Yarden Dali on 28/03/2024.
//

import SwiftUI
import MapKit
import MessageUI


struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showLocationSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                
                Section(header: Text("")) {
                    VStack(spacing: 10) {
                        VStack(spacing: 10) {
                                Image("Icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))

                            Text("SIDDUR_APP_ABOUT_LOC")
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                                .padding(.horizontal)
                                .font(.caption)
                        }
                    }
                    IconNavLink(iconImage: "info.circle.fill",
                                linkName: "ABOUT_LOC_STRING",
                                iconColor: Color.purple,
                                destination: AboutView())
                    
                    IconNavLink(iconImage: "envelope.fill",
                                linkName: "CONTACT_LOC",
                                iconColor: Color.mint,
                                destination: ContactDevView())
                    
                }
                
                Section(header: Text("SETTINGS_LOC_STRING")) {
                    IconNavLink(iconImage: "textformat.characters",
                                linkName: "FONT_SELECTION_LOC",
                                iconColor: .green,
                                destination: FontSelectionView())
                    
                    IconNavLink(iconImage: "globe",
                                linkName: "APP_LANG_LOC",
                                iconColor: Color.blue,
                                destination: LanguageSettingsView())
                }
                
                Section(header: Text("PERSONAL_SETTINGS_LOC"), footer: Text("SMART_SIDDUR_DESC_LOC")) {
                    Button(action: {
                        showLocationSheet.toggle()
                    }, label: {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6).fill(Color.yellow)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "house.fill").foregroundColor(.white)
                            }
                            Text(NSLocalizedString("PERSONAL_LOCATION_LOC", comment: ""))
                            Spacer()
                            if !appSettings.selectedLocation.isEmpty {
                                    Text(appSettings.selectedLocation)
                                        .foregroundStyle(.gray)
                                        .padding(.leading, 37)
                                        .transition(.opacity)
                                Button(action: {
                                    appSettings.selectedLocation = "" // Clear the location
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                    })
                    .foregroundStyle(.black)
                    .sheet(isPresented: $showLocationSheet) {
                        LocationSelectionView()
                            .presentationDragIndicator(.visible)
                    }

                    Toggle(isOn: $appSettings.smartSiddur) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6).fill(Color.gray)
                                    .frame(width: 28, height: 28)
                                Image(systemName: "character.book.closed.fill").foregroundColor(.white)
                            }
                            Text(NSLocalizedString("SMART_SIDDUR_TOGGLE_LOC", comment: ""))
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .disabled(true)
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
               
                    
            }
            .background(ImageBackgroundView())
            .scrollContentBackground(.hidden)
//            .navigationTitle("SETTINGS_LOC_STRING")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("SETTINGS_LOC_STRING")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
    //                            .foregroundStyle(CustomPalette.golden.color)
                    }
                }
            }

            .onChange(of: appSettings.selectedLocation) { oldValue, newValue in
                appSettings.selectedLocation = newValue
            }
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
//        .navigationBarTitle("PERSONAL_PASUK_LOC", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("PERSONAL_PASUK_LOC")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
//                            .foregroundStyle(CustomPalette.golden.color)
                }
            }
        }

    }
}


struct ContactDevView: View {
    
    @Environment(\.dismiss) var dismiss

    
    var body: some View {
        NavigationView {}
            .onAppear {
                sendFeedbackEmail()
                dismiss()
            }
    }
    
    private func sendFeedbackEmail() {
        if let mailURL = createFeedbackMailURL() {
            if UIApplication.shared.canOpenURL(mailURL) {
                UIApplication.shared.open(mailURL)
            } else {
                // Handle cases where the mail app cannot open
                print("Cannot send email: Mail app not available.")
            }
        }
    }
    
    
    private func createFeedbackMailURL() -> URL? {
        let subject = "Feedback for Suddir-Judaisim"
        let body = """
        Hi,
        
        I would like to share my thoughts about your app. Here's what I think:
        
        [Your feedback here]
        """
        
        let formattedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let formattedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let emailString = "mailto:\(feedbackEmail)?subject=\(formattedSubject)&body=\(formattedBody)"
        return URL(string: emailString)
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
