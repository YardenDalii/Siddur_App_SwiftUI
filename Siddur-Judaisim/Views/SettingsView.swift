//
//  SettingsView.swift
//  Siddur
//
//  Created by Yarden Dali on 28/03/2024.
//

import SwiftUI
import MapKit


struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showLocationSheet = false
    
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



struct LocationSelectionView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var searchLocationQuery: String = ""
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @State private var selectedLocation: MKLocalSearchCompletion?
    @State private var coordinates: CLLocationCoordinate2D?
    @State private var showConfirmationAlert: Bool = false // Alert state
    @Environment(\.dismiss) private var dismiss
    @StateObject private var geocodingHelper = GeocodingHelper()

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    List {
                        ForEach(geocodingHelper.searchResults, id: \.self) { result in
                            Button(action: {
                                selectedLocation = result
                                geocodingHelper.getCoordinate(addressString: result.title) { coordinate in
                                    if let coordinate = coordinate {
                                        coordinates = coordinate
                                        searchLocationQuery = result.title
                                        dismissKeyboard()
                                        showConfirmationAlert = true // Show confirmation alert
                                    }
                                }
                            }) {
                                VStack(alignment: .leading) {
                                    Text(result.title)
                                        .font(.headline)
                                        .foregroundStyle(.black)
                                    Text(result.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                    .background(ImageBackgroundView())
                    .scrollContentBackground(.hidden)
                }
                .searchable(text: $searchLocationQuery,
                            placement: .navigationBarDrawer(displayMode: .automatic),
                            prompt: "SEARCH_ADDRESS_PROMPT")
                .onChange(of: searchLocationQuery) { oldValue, newValue in
                    geocodingHelper.updateSearch(query: newValue)
                }
            }
            .navigationTitle("PERSONAL_LOCATION_LOC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("CANCEL_BUTTON") {
                        dismiss()
                    }
                    .foregroundStyle(CustomPalette.golden.color)
                }
            }
            .alert("Confirm Location", isPresented: $showConfirmationAlert) {
                Button("Accept") {
                    if let coordinates = coordinates, let locationName = selectedLocation?.title {
                        appSettings.selectedLatitude = coordinates.latitude
                        appSettings.selectedLongitude = coordinates.longitude
                        appSettings.selectedLocation = locationName
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {
                    // Do nothing and dismiss the alert
                }
            } message: {
                if let selectedLocation = selectedLocation {
                    Text("Do you want to save the location:\n\(selectedLocation.title)?\nThis location will be used for widgets and notifications.")
                } else {
                    Text("Do you want to save this location?")
                }
            }
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
