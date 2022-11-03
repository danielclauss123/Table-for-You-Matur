import Foundation
import Combine
import CoreLocation
import SystemConfiguration
import Algorithms
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class RestaurantRepo: ObservableObject {
    @Published private var restaurants = [Restaurant]()
    @Published private var yelpRestaurants = [YelpRestaurantDetail]()
    
    @Published var searchText = ""
    @Published private(set) var loadingStatus = Firestore.LoadingStatus.ready
    
    private let loadingService = LoadingService()
    
    let locationSearcher: LocationSearcher
    private var coordinateCancellable: AnyCancellable?
    private var lastCoordinateUpdate: CLLocationCoordinate2D?
    
    var searchedRestaurants: [YelpRestaurantDetail] {
        yelpRestaurants.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            .sorted(by: { $0.name < $1.name })
    }
    
    // MARK: Init
    init(locationSearcher: LocationSearcher) {
        self.locationSearcher = locationSearcher
        
        coordinateCancellable = locationSearcher.$coordinate.sink { coordinate in
            guard let coordinate = coordinate else { return }
            
            // The coordinate change gets ignored when it is under 5 km to prevent constant updates when the user moves around.
            guard self.lastCoordinateUpdate?.distance(from: coordinate) ?? .infinity > 5 * 1000 else {
                return
            }
            
            self.lastCoordinateUpdate = coordinate
            self.loadRestaurants()
        }
    }
    
    /// Example Init
    private init(restaurants: [Restaurant], yelpRestaurants: [YelpRestaurantDetail], locationSearcher: LocationSearcher) {
        self.restaurants = restaurants
        self.yelpRestaurants = yelpRestaurants
        self.locationSearcher = locationSearcher
    }
    
    // MARK: Load Restaurants
    func loadRestaurants() {
        loadingStatus = .loading
        
        Task {
            do {
                let response = try await loadingService.restaurants(atCoordinate: lastCoordinateUpdate)
                restaurants = response.firestore
                yelpRestaurants = response.yelp
                
                loadingStatus = .ready
            } catch is CancellationError {
                print("Loading restaurants task got canceled.")
            } catch LocationSearcher.LocationError.coordinateIsNil {
                loadingStatus = .error("Standort unbekannt")
                print("The location is nil.")
            } catch SCNetworkConnection.NetworkConnectionError.noConnection {
                loadingStatus = .error("Keine Internetverbindung")
                print("No network connection.")
            } catch {
                loadingStatus = .error("Fehler beim laden")
                print("Failed to load restaurants. Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Functions
    func restaurant(forYelpId yelpId: String) -> Restaurant? {
        restaurants.first(where: { $0.yelpId == yelpId })
    }
    
    // MARK: Example
    static let example = RestaurantRepo(restaurants: Restaurant.examples, yelpRestaurants: YelpRestaurantDetail.examples, locationSearcher: .example)
}

// MARK: - Loading Service
/// Manages all the loading of both the yelp and firestore restaurants..
private actor LoadingService {
    var currentTask: Task<Response, Error>?
    
    // MARK: Restaurants
    /// The firestore and yelp restaurants for a given location.
    func restaurants(atCoordinate coordinate: CLLocationCoordinate2D?) async throws -> Response {
        // Cancels any current task to prevent an older task finishing after a newer task.
        currentTask?.cancel()
        
        guard let coordinate = coordinate else {
            throw LocationSearcher.LocationError.coordinateIsNil
        }
        
        currentTask = Task {
            try await loadRestaurants(atCoordinate: coordinate)
        }
        
        if let result = try await currentTask?.value {
            return result
        } else {
            throw CancellationError()
        }
    }
    
    // MARK: Load Restaurants
    private func loadRestaurants(atCoordinate coordinate: CLLocationCoordinate2D) async throws -> Response {
        try SCNetworkConnection.checkConnection()
        
        let userGeohash4 = Geohash.encode(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude, 4
        )
        guard let neighborBuckets4 = Geohash.neighbors(userGeohash4) else {
            throw Geohash.GeohashError.noNeighborBuckets
        }
        let neighborBuckets3 = Array(neighborBuckets4.map { bucket4 -> String in
            var bucket3 = bucket4
            bucket3.removeLast()
            return bucket3
        }.uniqued())
        
        let reference = Firestore
            .collection(.restaurants)
            .whereField("isActive", isEqualTo: true)
            .whereField(FieldPath(["geoPoint", "geoHash3"]), in: neighborBuckets3)
        
        let snapshot = try await reference.getDocuments()
        let restaurants: [Restaurant] = snapshot.documents.compactMap { document in
            do {
                let restaurant = try document.data(as: Restaurant.self)
                if restaurant.coordinate.distance(from: coordinate) > 50 * 1000 {
                    return nil
                } else {
                    return restaurant
                }
            } catch {
                print("Failed to decode restaurant document \(document.documentID). Error: \(error.localizedDescription)")
                return nil
            }
        }
        
        let yelpRestaurants = await YelpRestaurantStore.shared.loadRestaurants(withIds: restaurants.map { $0.yelpId })
        
        return Response(firestore: restaurants, yelp: yelpRestaurants)
    }
    
    // MARK: Response
    /// The response of a loading request for the restaurants.
    struct Response {
        let firestore: [Restaurant]
        let yelp: [YelpRestaurantDetail]
    }
}
