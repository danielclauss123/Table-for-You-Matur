import Foundation
import Combine
import MapKit

class LocationSearcher: NSObject, ObservableObject, MKLocalSearchCompleterDelegate, CLLocationManagerDelegate {
    @Published var searchText = ""
    @Published var locationSource = LocationSource.undefined {
        didSet {
            guard locationSource != oldValue else { return }
            
            coordinate = nil
            
            if locationSource == .device {
                searchText = "Mein Standort"
                
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
            } else if locationSource == .map {
                searchText = "Kartenbereich"
                locationManager.stopUpdatingLocation()
            } else {
                searchText = ""
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    @Published private(set) var coordinate: CLLocationCoordinate2D?
    @Published private(set) var searchCompletions = [MKLocalSearchCompletion]()
    @Published private(set) var locationServiceAvailable = false
    @Published private(set) var errorMessage: String?
    
    private let localSearchCompleter = MKLocalSearchCompleter()
    private var cancellables = [AnyCancellable]()
    
    private let locationManager = CLLocationManager()
    
    // MARK: Init
    override init() {
        super.init()
        
        localSearchCompleter.delegate = self
        localSearchCompleter.resultTypes = .address
        
        locationManager.delegate = self
        
        $searchText
            .dropFirst()
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { text in
                if self.locationSource == .search {
                    self.errorMessage = nil
                }
                
                if text.isEmpty || self.locationSource != .search {
                    self.searchCompletions = []
                } else {
                    self.localSearchCompleter.queryFragment = text
                }
            }
            .store(in: &cancellables)
        
        locationSource = .device
    }
    
    /// Example init.
    private init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.locationSource = .search
        self.searchText = "Example Coordinate"
    }
    
    // MARK: Deinit
    deinit {
        localSearchCompleter.cancel()
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Select Completion
    @MainActor func selectCompletion(_ searchCompletion: MKLocalSearchCompletion) async {
        searchText = searchCompletion.fullText
        
        do {
            coordinate = try await searchCompletion.coordinate()
        } catch {
            errorMessage = "Laden der Koordinaten fehlgeschlagen."
            print("Failed to produce coordinate from completion: \(searchCompletion). Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Select Map Coordinate
    @MainActor func selectMapCoordinate(_ mapCenter: CLLocationCoordinate2D) {
        locationSource = .map
        coordinate = mapCenter
    }
    
    // MARK: Search Completer Delegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchCompletions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        errorMessage = "Laden der Suchresultate fehlgeschlagen."
        print("MKLocalSearchCompleter failed with text: \(completer.queryFragment). Error: \(error.localizedDescription)")
    }
    
    // MARK: Location Manager Delegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationServiceAvailable = manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways
        
        if locationServiceAvailable && coordinate == nil {
            locationSource = .device
        } else if !locationServiceAvailable && locationSource == .device {
            locationSource = .undefined
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locationSource == .device {
            coordinate = locations.last?.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Standortbestimmung fehlgeschlagen."
        print("CLLocationManager failed. Error: \(error.localizedDescription)")
    }
    
    // MARK: Location Source
    enum LocationSource {
        case device, search, map, undefined
    }
    
    // MARK: Example
    static let example = LocationSearcher(coordinate: .init(latitude: 47.49230, longitude: 8.73363))
}

// MARK: - Location Error
extension LocationSearcher {
    enum LocationError: Error, LocalizedError {
        case coordinateIsNil
        
        var errorDescription: String {
            switch self {
            case .coordinateIsNil:
                return "The coordinate value is nil."
            }
        }
    }
}
