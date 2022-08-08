import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine
import CoreLocation
import Algorithms

@MainActor
class RestaurantRepository: ObservableObject {
    @Published private var restaurants = [Restaurant]()
    @Published private var yelpRestaurants = [YelpRestaurantDetail]()
    
    @Published var searchText = ""
    
    @Published private(set) var loadingStatus = LoadingStatus.ready
    
    let locationSearcher: LocationSearcher
    private var coordinateCancellable: AnyCancellable?
    private var lastCoordinateUpdate: CLLocationCoordinate2D?
    
    private let yelpLoadingService = YelpLoadingService()
    
    private var currentListener: ListenerRegistration?
    private var currentListenerId: UUID?
    
    var searchedRestaurants: [YelpRestaurantDetail] {
        yelpRestaurants.filter { $0.name.lowercased().hasPrefix(searchText.lowercased()) }
    }
    
    // MARK: - Initializer
    init(locationSearcher: LocationSearcher) {
        self.locationSearcher = locationSearcher
        
        coordinateCancellable = locationSearcher.$coordinate.sink { coordinate in
            // The coordinate change should only be looked at when it is bigger than 5km, because if the smallest change is leading to an update of the restaurants, the are constant updates, because the user always moves.
            if let coordinate = coordinate {
                if let lastCoordinateUpdate = self.lastCoordinateUpdate {
                    if coordinate.distance(from: lastCoordinateUpdate) > 5 * 1000 {
                        self.lastCoordinateUpdate = coordinate
                        self.addFirestoreListener(forCoordinate: coordinate)
                    }
                } else {
                    self.lastCoordinateUpdate = coordinate
                    self.addFirestoreListener(forCoordinate: coordinate)
                }
            }
        }
    }
    
    // MARK: - Add Firestore Listener
    func addFirestoreListener(forCoordinate coordinate: CLLocationCoordinate2D) {
        loadingStatus = .loading
        restaurants = []
        yelpRestaurants = []
        currentListener?.remove()
        
        let userGeoHash4 = Geohash.encode(latitude: coordinate.latitude, longitude: coordinate.longitude, 4)
        guard let neighborBuckets4 = Geohash.neighbors(userGeoHash4) else {
            loadingStatus = .firestoreError("Failed to produce the neighbor buckets for the user location.")
            return
        }
        
        let neighborBuckets3 = Array(neighborBuckets4.map { bucket4 -> String in
            var bucket3 = bucket4
            bucket3.removeLast()
            return bucket3
        }.uniqued())
        
        let listenerId = UUID()
        self.currentListenerId = listenerId
        
        currentListener = Firestore.collection(.restaurants)
            .whereField("isActive", isEqualTo: true)
            .whereField(FieldPath(["geoPoint", "geoHash3"]), in: neighborBuckets3)
            .addSnapshotListener { snapshot, error in
                guard self.currentListenerId == listenerId else {
                    print("Different listener that gets executed then the current one.")
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("Failed to load restaurants from firebase: \(error?.localizedDescription ?? "Snapshot is nil.")")
                    self.loadingStatus = .firestoreError(error?.localizedDescription ?? "Unknown Error")
                    return
                }
                
                self.restaurants = snapshot.documents.compactMap { document in
                    do {
                        let restaurant = try document.data(as: Restaurant.self)
                        if restaurant.coordinate.distance(from: coordinate) > 50 * 1000 {
                            return nil
                        } else {
                            return restaurant
                        }
                    } catch {
                        print("Failed to decode document: \(error.localizedDescription)")
                        
                        return nil
                    }
                }
                
                Task {
                    do {
                        let yelpRestaurants = try await self.yelpLoadingService.loadRestaurants(withIds: self.restaurants.map { $0.yelpId })
                        
                        guard self.currentListenerId == listenerId else {
                            print("Different listener that gets executed then the current one.")
                            return
                        }
                        
                        self.yelpRestaurants = yelpRestaurants
                        self.loadingStatus = .ready
                    } catch is CancellationError {
                        print("Task got canceled.")
                    } catch {
                        self.loadingStatus = .yelpError(error.localizedDescription)
                        print("Loading request for yelp restaurants failed: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    // MARK: - Loading Status
    enum LoadingStatus {
        case ready, loading, firestoreError(String), yelpError(String)
    }
    
    // MARK: - Functions
    func restaurant(forYelpId yelpId: String) -> Restaurant? {
        restaurants.first(where: { $0.yelpId == yelpId })
    }
}

// MARK: - Yelp Loading Service
/// An actor that manages the loading of the yelp restaurants. It cancels old tasks and only returns the newest data.
private actor YelpLoadingService {
    var currentTask: Task<[YelpRestaurantDetail], Error>?
    
    func loadRestaurants(withIds ids: [String]) async throws -> [YelpRestaurantDetail] {
        // Cancels any current task to prevent an older task finishing after a newer task.
        currentTask?.cancel()
        
        currentTask = Task {
            try await YelpRestaurantStore.shared.loadRestaurants(withIds: ids)
        }
        
        if let result = try await currentTask?.value {
            return result
        } else {
            throw CancellationError()
        }
    }
}
