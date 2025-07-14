//
//  LocationManager.swift
//  Siddur-Judaisim
//
//  Created by Yarden Dali on 08/04/2024.
//

import Foundation
import CoreLocation
import MapKit
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    @Published private(set) var currentLocation: CLLocationCoordinate2D?
    var locationUpdated: ((CLLocationCoordinate2D) -> Void)?
    
    @Published var savedLocations: [LocationItem] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // You might want to trigger location updates based on changes in the app's lifecycle or user actions.
        // Consider moving the requestLocation call to a more appropriate place if needed.
        
        loadLocations()
    }
    
    func requestAuthorizationIfNeeded() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break // Handle other cases as needed.
        }
    }
    
    func requestLocation() {
        requestAuthorizationIfNeeded()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async { [weak self] in
            self?.currentLocation = location.coordinate
            
            print("Updated Location - Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
            
            // Optionally, stop updating location to conserve battery, or adjust based on your app's needs.
            self?.locationManager.stopUpdatingLocation()
            
            // Call the callback with the new location if it's set
            if let location = self?.currentLocation {
                self?.locationUpdated?(location)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Handle changes in authorization status if needed.
    }
    
    
    func saveLocations() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(savedLocations)
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let filePath = paths[0].appendingPathComponent("locations.json")
            try data.write(to: filePath, options: .atomicWrite)
            print("Saved successfully to \(filePath)")
        } catch {
            print("Error encoding or saving: \(error)")
        }
    }
    
    func loadLocations() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent("locations.json")
        
        if let data = try? Data(contentsOf: filePath) {
            let decoder = JSONDecoder()
            if let locations = try? decoder.decode([LocationItem].self, from: data) {
                print("Loaded successfully from \(filePath)")
                savedLocations = locations
                return
            }
        }
        
        if let bundledPath = Bundle.main.path(forResource: "locations", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: bundledPath)) {
            let decoder = JSONDecoder()
            if let locations = try? decoder.decode([LocationItem].self, from: data) {
                print("Loaded fresh json from \(bundledPath)")
                savedLocations = locations
                return
            }
        }
        
        
        if let location = self.currentLocation {
            savedLocations = [ LocationItem(name: "Local", symbol: "location.fill", latitude: location.latitude, longitude: location.longitude)]
        } else {
            savedLocations = []
        }
    }
}




struct LocationItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var symbol: String
    var latitude: Double
    var longitude: Double
}





class GeocodingHelper: NSObject, ObservableObject {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    private var searchCompleter: MKLocalSearchCompleter
    
    override init() {
        self.searchCompleter = MKLocalSearchCompleter()
        self.searchCompleter.resultTypes = .address
        super.init()
        self.searchCompleter.delegate = self
    }
    
    func updateSearch(query: String) {
        searchCompleter.queryFragment = query
    }
    
    func getCoordinate(addressString: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { placemarks, error in
            guard error == nil else {
                print("Geocoding error: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            completion(placemarks?.first?.location?.coordinate)
        }
    }
}



extension GeocodingHelper: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search completer error: \(error.localizedDescription)")
    }
}
