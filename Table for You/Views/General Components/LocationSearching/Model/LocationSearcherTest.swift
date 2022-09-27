import Foundation
import MapKit
import Combine
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Last location is the most current.
    }
}

class TestLocationSearcher: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchText = ""
    
    @Published private(set) var coordinate: CLLocationCoordinate2D?
    @Published private(set) var errorMessage: String?
    
    @Published private(set) var searchCompletions = [MKLocalSearchCompletion]()
    
    private let localSearchCompleter = MKLocalSearchCompleter()
    
    private var cancellables = [AnyCancellable]()
    
    override init() {
        super.init()
        
        localSearchCompleter.delegate = self
        localSearchCompleter.resultTypes = .address
        
        $searchText
            .sink { _ in
                // Set coordinate to nil
            }
            .store(in: &cancellables)
        $searchText
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { text in
                
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func selectSearchCompletion(_ searchCompletion: MKLocalSearchCompletion) async {
        
    }
}
