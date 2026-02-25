//
//  ZemanimView.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 04/04/2024.
//

import SwiftUI
import Hebcal
import MapKit
import UIKit

struct ZemanimView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var locationManager: LocationManager
    
    @StateObject private var viewModel = HebrewTimeModel()
    
    @State private var showAddLocationSheet = false
    
    @State var localLocation: LocationItem?
    
    @State private var selection: Date?
    @State private var title: String = Calendar.monthAndYear(from: .now)
    @State private var hTitle: String = Calendar.hebrewMonthAndYear(from: .now)
    @State private var focusedWeek: Week = .current
    @State private var calendarType: CalendarType = .week
    @State private var isDragging: Bool = false
    
    @State private var dragProgress: CGFloat = .zero
    @State private var initialDragOffset: CGFloat? = nil
    @State private var verticalDragOffset: CGFloat = .zero
    
    private let symbols = ["DAYONE", "DAYTWO", "DAYTHREE", "DAYFOUR", "DAYFIVE", "DAYSIX", "DAYSEVEN"]
    
    enum CalendarType {
        case week, month
    }
    
    var body: some View {
        NavigationStack {
            CalendarView(
                title: $title,
                hTitle: $hTitle,
                selection: $selection,
                focusedWeek: $focusedWeek,
                calendarType: $calendarType,
                isDragging: $isDragging,
                dragProgress: $dragProgress,
                initialDragOffset: $initialDragOffset,
                verticalDragOffset: $verticalDragOffset,
                symbols: symbols
            )
            VStack {
                if localLocation != nil {
                    ScrollView {
                        VStack {
                            if let temp = localLocation {
                                ExpandableCardView(item: temp)
                                
                                ForEach(locationManager.savedLocations) { location in
                                    ExpandableCardView(item: location)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                deleteLocation(location)
                                            } label: {
                                                Label("DELETE_LOC_STRING", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                    
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                }
            }
            .background(ImageBackgroundView())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddLocationSheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundStyle(CustomPalette.golden.color)
                    }
                }
//                ToolbarItem(placement: .topBarLeading) {
//                    Text(hTitle)
//                        .fontWeight(.medium)
//                        .foregroundStyle(CustomPalette.golden.color)
//                        .frame(width: 120)
//                }
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("ZEMANIM")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
//                        Text(Locale.current.identifier.starts(with: "en") ? HDate(date: appSettings.currentDate, calendar: .current).render(lang: TranslationLang.en) : HDate(date: appSettings.currentDate, calendar: .current).render(lang: TranslationLang.he))
//                            .font(.system(size: 16, weight: .medium, design: .rounded))
//                            .foregroundStyle(CustomPalette.lightGray.color)
//                            .lineLimit(1)
//                            .minimumScaleFactor(0.7)
                    }
                }
            }
            .sheet(isPresented: $showAddLocationSheet) {
                AddLocationView()
                    .environmentObject(appSettings)
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                if let location = locationManager.currentLocation {
                    viewModel.fetchZmanim(latitude: location.latitude, longitude: location.longitude)
                    viewModel.fetchShabbatTimes(latitude: location.latitude, longitude: location.longitude)
                    localLocation = LocationItem(name: "Local", symbol: "location.fill", latitude: location.latitude, longitude: location.longitude)
                    print("Location: \(location)")
                    print("Latitude: \(location.latitude), Longitude: \(location.longitude)")
                }
            }
        }
        
    }
    
    private func deleteLocation(_ location: LocationItem) {
        if let index = locationManager.savedLocations.firstIndex(where: { $0.id == location.id }) {
            locationManager.savedLocations.remove(at: index)
            locationManager.saveLocations()
        }
    }
}



struct ExpandableCardView: View {

    let item: LocationItem
    @StateObject private var viewModel = HebrewTimeModel()
    @State private var isExpanded = false
    @State private var hasAppeared = false
    
    private var chevronRotation: Double {
        isExpanded ? 180 : 0
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                // Accent bar on the left side
                RoundedRectangle(cornerRadius: 20)
                    .fill(CustomPalette.golden.color)
                    .frame(width: isExpanded ? 6 : 0)
                    .animation(.bouncy(duration: 0.5, extraBounce: 0.15), value: isExpanded)
                    .padding(.vertical, 6)
                    .padding(.leading, 4)
                    .offset(x: 0, y: 0)
                
                VStack(alignment: .leading) {
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        withAnimation(.bouncy(duration: 0.5, extraBounce: 0.15)) {
                            isExpanded.toggle()
                        }
                    } label: {
                        if !isExpanded {
                            HStack {
                                VStack(alignment: .leading) {
                                    
                                    HStack {
                                        Image(systemName: "\(item.symbol)")
                                            .foregroundColor(.black)
                                        Text("\(NSLocalizedString(item.name, comment: ""))")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        Spacer()
                                        
                                        Image(systemName:"chevron.down")
                                            .rotationEffect(.degrees(chevronRotation))
                                            .animation(.easeInOut(duration: 0.3), value: chevronRotation)
                                            .foregroundStyle(.black)
                                            .padding(.trailing, 10)
                                    }
                                    
                                    if !viewModel.eventTimes.isEmpty {
                                        VStack(alignment: .leading, spacing: 4) {
                                            let currentTime = Date()
                                            let upcomingEvents = viewModel.eventTimes.filter { $0.date > currentTime }.prefix(3)
                                            
                                            if upcomingEvents.isEmpty {
                                                Text("NO_UPCOMING_EVENTS_LOC")
                                                    .font(.subheadline)
                                                    .foregroundColor(.black)
                                            } else {
                                                ForEach(Array(upcomingEvents), id: \.eventName) { event in
                                                    HStack {
                                                        Text(NSLocalizedString(event.eventName, comment: ""))
                                                        Spacer()
                                                        Text(event.localTimeString)
                                                    }
                                                    .foregroundStyle(.black)
                                                    .font(.subheadline)
                                                    .padding(.trailing)
                                                }
                                            }
                                        }
                                    } else {
                                        Text("LOADING_EVENTS_LOC")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                    }
                                    
                                    Spacer()
                                    
                                }
                                .padding(16)
                                .padding(.leading, 10)
                            }
                            .frame(height: 140)
                        } else {
                            VStack {
                                HStack {
                                    Image(systemName: "\(item.symbol)")
                                        .foregroundColor(.black)
                                    Text("\(NSLocalizedString(item.name, comment: ""))")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName:"chevron.down")
                                        .rotationEffect(.degrees(chevronRotation))
                                        .animation(.easeInOut(duration: 0.3), value: chevronRotation)
                                        .foregroundStyle(.black)
                                        .padding(.trailing, 10)
                                }
                                .padding(.leading, 10)
                                
                                TimeDetailView(viewModel: viewModel, location: item)
                            }
                            .padding(16)
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .top).combined(with: .scale(scale: 0.9, anchor: .top)).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .scale(scale: 0.9, anchor: .top)).combined(with: .opacity)
                        )
                    )
                }
                .background(
                    ZStack {
                        // Blur glass background
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                        
                        // Gradient overlay
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.9, green: 0.85, blue: 0.8).opacity(0.8),
                                Color(red: 0.8, green: 0.7, blue: 0.6).opacity(0.8)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .frame(maxHeight: isExpanded ? .infinity : 150)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
        .opacity(hasAppeared ? 1 : 0)
        .scaleEffect(hasAppeared ? 1 : 0.92)
        .animation(.bouncy(duration: 0.5, extraBounce: 0.15), value: isExpanded)
        .onAppear {
            viewModel.fetchZmanim(latitude: item.latitude, longitude: item.longitude)
            viewModel.fetchShabbatTimes(latitude: item.latitude, longitude: item.longitude)
            withAnimation(.bouncy(duration: 0.65, extraBounce: 0.18)) {
                hasAppeared = true
            }
        }
    }
}



struct TimeDetailView: View {
    @ObservedObject var viewModel: HebrewTimeModel
    let location: LocationItem

    var body: some View {
        VStack {

            if !viewModel.eventTimes.isEmpty {
                VStack {
                    Label("\(viewModel.parasha?.hebrew ?? "")", systemImage: "book.pages.fill")
                        .bold()
                        .foregroundStyle(.black)
                    Divider()
                    if !viewModel.shabbatTimes.isEmpty {
                        ForEach(viewModel.shabbatTimes, id: \.title) { item in
                            HStack {
                                Text(NSLocalizedString("\(item.category ?? "")", comment: "")).bold()
                                Spacer()
                                Text("\(item.date)")
                            }
                            .foregroundStyle(.black)
                            .padding(.top, 5)
                        }
                    } else {
                        Text("FETCHING_SHABBAT_TIMES")
                    }
                }


                VStack {
                    Label("DAILY_TIMES_ZMANIM", systemImage: "clock.fill")
                        .bold()
                        .foregroundStyle(.black)
                    Divider()
                    ForEach(viewModel.eventTimes, id: \.eventName) { event in
                        HStack {
                            Text(NSLocalizedString(event.eventName, comment: "")).bold()
                            Spacer()
                            Text(event.localTimeString)
                        }
                        .foregroundStyle(.black)
                        .padding(.top, 5)
                    }
                }
                .padding(.top, 10)

            } else {
                Text("FETCHING_ZMANIM")
            }
        }
        .padding()
        .cornerRadius(10)
    }
}



struct AddLocationView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var locationManager: LocationManager
    @State private var searchQuery: String = ""
    @State private var selectedLocation: MKLocalSearchCompletion?
    @State private var coordinates: CLLocationCoordinate2D?
    @State private var selectedSymbol: String = "location.fill" // Default symbol
    @Environment(\.dismiss) private var dismiss
    @StateObject private var geocodingHelper = GeocodingHelper()
    
    let symbols = ["location.fill", "star.fill", "mappin.and.ellipse", "house.fill"]
    
    init() {
        // Customize UISearchTextField appearance
        let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textFieldAppearance.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("SEARCH_ADDRESS_PROMPT", comment: ""),
            attributes: [.foregroundColor: UIColor.white]
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    List {
                        ForEach(geocodingHelper.searchResults, id: \.self) { result in
                            Button(action: {
                                selectedLocation = result
                                geocodingHelper.getCoordinate(addressString: result.title) { coordinate in
                                    if let coordinate = coordinate {
                                        coordinates = coordinate
                                        searchQuery = result.title
                                        dismissKeyboard()
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
                        
                        if let coordinates = coordinates {
                            Section {
                                Picker("SYMBOL_SELECTION_ZMANIM", selection: $selectedSymbol) {
                                    ForEach(symbols, id: \.self) { symbol in
                                        Image(systemName: symbol)
                                            .tag(symbol)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding()
                                
                                Button(action: {
                                    if let selectedLocation = selectedLocation {
                                        let newLocation = LocationItem(
                                            name: selectedLocation.title,
                                            symbol: selectedSymbol,
                                            latitude: coordinates.latitude,
                                            longitude: coordinates.longitude
                                        )
                                        locationManager.savedLocations.append(newLocation)
                                        locationManager.saveLocations()
                                        dismiss()
                                    }
                                }) {
                                    Text("ADD_LOCATION_BUTTON_ZMANIM")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(CustomPalette.blue.color)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
//                    .listStyle(InsetGroupedListStyle())
                    .padding(.top, 8)
                    .background(ImageBackgroundView())
                    .scrollContentBackground(.hidden)
                }
                .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "SEARCH_ADDRESS_PROMPT")
                .onChange(of: searchQuery) { oldValue, newValue in
                    geocodingHelper.updateSearch(query: newValue)
                }
                .navigationTitle("ADD_LOCATION_BUTTON_ZMANIM")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("CANCEL_BUTTON") {
                            dismiss()
                        }
                        .foregroundStyle(CustomPalette.golden.color)
                    }
                }
            }
            
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}




#Preview {
    SiddurView()
        .environmentObject(AppSettings())
        .environmentObject(LocationManager())
}

