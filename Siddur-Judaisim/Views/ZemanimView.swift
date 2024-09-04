//
//  ZemanimView.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 04/04/2024.
//

import SwiftUI
import Hebcal
import MapKit



//struct ZemanimView: View {
//    @EnvironmentObject var appSettings: AppSettings
//    @EnvironmentObject var locationManager: LocationManager
//    
//    @StateObject private var viewModel = HebrewTimeModel()
//    
//    @State private var showTitle = false
//    @State private var showAddLocationSheet = false
//    
//    @State var localLocation: LocationItem?
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                if localLocation != nil {
//                    ScrollView {
//                        VStack {
//                            headerView
//                            
//                            if let temp = localLocation {
//                                ExpandableCardView(item: temp)
//                                    .padding(.horizontal)
//                            }
//                            
//                            ForEach(locationManager.savedLocations) { location in
//                                ExpandableCardView(item: location)
//                                    .padding(.horizontal)
//                                    .contextMenu {
//                                        Button(role: .destructive) {
//                                            deleteLocation(location)
//                                        } label: {
//                                            Label("DELETE_LOC_STRING", systemImage: "trash")
//                                        }
//                                    }
//                            }
//                        }
//                    }
//                    .coordinateSpace(name: "scroll")
//                } else {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .scaleEffect(2)
//                }
//            }
//            .background {
//                Image("pageBG")
//            }
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationTitle(showTitle ? "ZEMANIM" : "")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        showAddLocationSheet = true
//                    }) {
//                        Image(systemName: "plus")
//                            .foregroundStyle(CustomPalette.golden.color)
//                    }
//                }
//            }
//            .sheet(isPresented: $showAddLocationSheet) {
//                AddLocationView()
//                    .environmentObject(appSettings)
//            }
//            .onAppear {
//                if let location = locationManager.currentLocation {
//                    viewModel.fetchZmanim(latitude: location.latitude, longitude: location.longitude)
//                    viewModel.fetchShabbatTimes(latitude: location.latitude, longitude: location.longitude)
//                    localLocation = LocationItem(name: "Local", symbol: "location.fill", latitude: location.latitude, longitude: location.longitude)
//                    print("Location: \(location)")
//                    print("Latitude: \(location.latitude), Longitude: \(location.longitude)")
//                }
//            }
//        }
//        
//    }
//    
//    @ViewBuilder
//    var headerView: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                if Locale.current.identifier.starts(with: "en") {
//                    Text(HDate(date: appSettings.currentDate, calendar: .current).render(lang: TranslationLang.en))
//                        .foregroundStyle(CustomPalette.lightGray.color)
//                        .bold()
//                } else {
//                    Text(HDate(date: appSettings.currentDate, calendar: .current).render(lang: TranslationLang.he))
//                        .foregroundStyle(CustomPalette.lightGray.color)
//                        .bold()
//                }
//                Text("ZEMANIM")
//                    .font(.largeTitle)
//                    .bold()
//            }
//            
//            Spacer()
//            
//        }
//        .padding(.leading)
//        
//        GeometryReader { geometry in
//            Color.clear
//                .onChange(of: geometry.frame(in: .named("scroll")).origin.y) {
//                    if (geometry.frame(in: .named("scroll")).origin.y < 40) {
//                        self.showTitle = true
//                    } else {
//                        self.showTitle = false
//                    }
//                }
//        }
//        .frame(height: 0)
//    }
//    
//    private func deleteLocation(_ location: LocationItem) {
//        if let index = locationManager.savedLocations.firstIndex(where: { $0.id == location.id }) {
//            locationManager.savedLocations.remove(at: index)
//            locationManager.saveLocations()
//        }
//    }
//}



struct ZemanimView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var locationManager: LocationManager
    
    @StateObject private var viewModel = HebrewTimeModel()
    
    @State private var showAddLocationSheet = false
    
    @State var localLocation: LocationItem?
    
    var body: some View {
        NavigationStack {
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
            .background {
                Image("pageBG")
            }
            .navigationTitle("ZEMANIM")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showAddLocationSheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundStyle(CustomPalette.golden.color)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if Locale.current.identifier.starts(with: "en") {
                        Text(HDate(date: appSettings.currentDate, calendar: .current).render(lang: TranslationLang.en))
                            .foregroundStyle(CustomPalette.lightGray.color)
                            .bold()
                    } else {
                        Text(HDate(date: appSettings.currentDate, calendar: .current).render(lang: TranslationLang.he))
                            .foregroundStyle(CustomPalette.lightGray.color)
                            .bold()
                    }
                }
            }
            .sheet(isPresented: $showAddLocationSheet) {
                AddLocationView()
                    .environmentObject(appSettings)
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
    
    @AppStorage("appearanceSettingKey") var appearance: String = "light"
    
    let item: LocationItem
    @StateObject private var viewModel = HebrewTimeModel()
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading) {
                    if !isExpanded {
                        Button {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        } label: {
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
                                                    Text("\(NSLocalizedString(event.eventName, comment: "")): \(event.localTimeString)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.black)
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
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.9, green: 0.85, blue: 0.8),  // Light beige/brownish tone
                                        Color(red: 0.8, green: 0.7, blue: 0.6)    // Soft light brown
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    } else {
                        Button {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        } label: {
                            VStack {
                                HStack {
                                    Image(systemName: "\(item.symbol)")
                                        .foregroundColor(.black)
                                    Text("\(NSLocalizedString(item.name, comment: ""))")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName:"chevron.up")
                                        .foregroundStyle(.black)
                                        .padding(.trailing, 10)
                                }
                                .padding(.leading, 10)
                                
                                TimeDetailView(location: item)
                            }
                            .padding(16)
                        }
                        
                    }
                    
                }
            }
            .frame(maxHeight: isExpanded ? .infinity : 150)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.9, green: 0.85, blue: 0.8),  // Light beige/brownish tone
                        Color(red: 0.8, green: 0.7, blue: 0.6)    // Soft light brown
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .onAppear {
            viewModel.fetchZmanim(latitude: item.latitude, longitude: item.longitude)
            viewModel.fetchShabbatTimes(latitude: item.latitude, longitude: item.longitude)
        }
    }
}



struct TimeDetailView: View {
    @StateObject private var viewModel = HebrewTimeModel()
    let location: LocationItem
    
    var body: some View {
        VStack {
            
            if !self.viewModel.eventTimes.isEmpty {
                VStack {
                    Label("\(self.viewModel.parasha?.hebrew ?? "")", systemImage: "book.pages.fill")
                        .bold()
                        .foregroundStyle(.black)
                    Divider()
                    if !self.viewModel.shabbatTimes.isEmpty {
                        ForEach(self.viewModel.shabbatTimes, id: \.title) { item in
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
                    ForEach(self.viewModel.eventTimes, id: \.eventName) { event in
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
        .onAppear {
            self.viewModel.fetchZmanim(latitude: location.latitude, longitude: location.longitude)
            self.viewModel.fetchShabbatTimes(latitude: location.latitude, longitude: location.longitude)
        }
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
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(geocodingHelper.searchResults, id: \.self) { result in
                        Button(action: {
                            selectedLocation = result
                            geocodingHelper.getCoordinate(addressString: result.title) { coordinate in
                                if let coordinate = coordinate {
                                    coordinates = coordinate
                                    searchQuery = result.title
                                }
                            }
                        }) {
                            VStack(alignment: .leading) {
                                Text(result.title)
                                    .font(.headline)
                                Text(result.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
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
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "SEARCH_ADDRESS_PROMPT")
                .onChange(of: searchQuery) { oldValue, newValue in
                    geocodingHelper.updateSearch(query: newValue)
                }
                .navigationTitle("ADD_LOCATION_BUTTON_ZMANIM")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("CANCEL_BUTTON") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}




#Preview {
    SiddurView()
        .environmentObject(AppSettings())
        .environmentObject(LocationManager())
}
