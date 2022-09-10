import Foundation
import Combine
import SystemConfiguration
import FirebaseFirestore

@MainActor
class UserReservationsVM: ObservableObject {
    @Published private(set) var yelpRestaurants = [YelpRestaurantDetail]()
    
    @Published private(set) var yelpLoadingStatus = Firestore.LoadingStatus.ready
    
    private let loadingService = LoadingService()
    
    private var reservationsCancellable: AnyCancellable?
    
    var currentReservations: [Reservation] {
        UserReservationsRepo.shared.currentReservations
    }
    
    var pastReservations: [Reservation] {
        UserReservationsRepo.shared.pastReservations
    }
    
    // MARK: Init
    init() {
        reservationsCancellable = UserReservationsRepo.shared.$reservations.sink {
            self.loadYelpRestaurants(withIds: $0.map { $0.yelpId })
        }
    }
    
    // MARK: Load Yelp Restaurants
    private func loadYelpRestaurants(withIds ids: [String]) {
        yelpLoadingStatus = .loading
        
        Task {
            do {
                self.yelpRestaurants = try await self.loadingService.yelpRestaurants(withIds: ids)
            } catch is CancellationError {
                print("Loading restaurants task got canceled.")
            } catch SCNetworkConnection.NetworkConnectionError.noConnection {
                self.yelpLoadingStatus = .error("Keine Internetverbindung")
                print("No network connection.")
            } catch {
                self.yelpLoadingStatus = .error("Fehler beim laden")
                print("Failed to load yelp restaurants. Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Functions
    func yelpRestaurant(withId id: String) -> YelpRestaurantDetail? {
        yelpRestaurants.first(where: { $0.id == id })
    }
}

// MARK: - Loading Service
/// Manages all the loading of both the yelp and firestore restaurants..
private actor LoadingService {
    var currentTask: Task<[YelpRestaurantDetail], Error>?
    
    // MARK: Yelp Restaurants
    /// The firestore and yelp restaurants for a given location.
    func yelpRestaurants(withIds ids: [String]) async throws -> [YelpRestaurantDetail] {
        // Cancels any current task to prevent an older task finishing after a newer task.
        currentTask?.cancel()
        
        try SCNetworkConnection.checkConnection()
        
        currentTask = Task {
            await YelpRestaurantStore.shared.loadRestaurants(withIds: ids)
        }
        
        if let result = try await currentTask?.value {
            return result
        } else {
            throw CancellationError()
        }
    }
}
