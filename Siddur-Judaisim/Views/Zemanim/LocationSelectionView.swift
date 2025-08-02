//
//  LocationSelectionView.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 10/12/2024.
//

import SwiftUI
import MapKit
import UIKit


struct LocationSelectionView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var searchLocationQuery: String = ""
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @State private var selectedLocation: MKLocalSearchCompletion?
    @State private var coordinates: CLLocationCoordinate2D?
    @State private var showConfirmationAlert: Bool = false // Alert state
    @Environment(\.dismiss) private var dismiss
    @StateObject private var geocodingHelper = GeocodingHelper()
    
    init() {
        // Customize UISearchTextField appearance
        let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textFieldAppearance.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("SEARCH_ADDRESS_PROMPT", comment: ""),
            attributes: [.foregroundColor: UIColor.white]
        )
    }
    
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


#Preview {
    LocationSelectionView()
}
