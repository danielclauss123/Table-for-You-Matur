import Foundation
import SystemConfiguration
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class RoomRepo: ObservableObject {
    @Published private(set) var rooms = [Room]()
    
    @Published private(set) var loadingStatus = Firestore.LoadingStatus.ready
    
    let restaurant: Restaurant
    
    private let loadingService = LoadingService()
    
    // MARK: Init
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        
        loadRooms()
    }
    
    /// Example Init
    private init(restaurant: Restaurant, rooms: [Room]) {
        self.restaurant = restaurant
        self.rooms = rooms
    }
    
    // MARK: Load Rooms
    func loadRooms() {
        loadingStatus = .loading
        
        Task {
            do {
                rooms = try await loadingService.rooms(ofRestaurant: restaurant)
                loadingStatus = .ready
            } catch is CancellationError {
                print("Loading restaurants task got canceled.")
            } catch SCNetworkConnection.NetworkConnectionError.noConnection {
                loadingStatus = .error("Keine Internetverbindung")
                print("No network connection.")
            } catch {
                loadingStatus = .error("Fehler beim laden")
                print("Failed to load restaurants. Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Example
    static let example = RoomRepo(restaurant: .example, rooms: Room.examples)
}

// MARK: - Loading Service
private actor LoadingService {
    var currentTask: Task<[Room], Error>?
    
    // MARK: Rooms
    /// The firestore and yelp restaurants for a given location.
    func rooms(ofRestaurant restaurant: Restaurant) async throws -> [Room] {
        // Cancels any current task to prevent an older task finishing after a newer task.
        currentTask?.cancel()
        
        currentTask = Task {
            try await loadRooms(ofRestaurant: restaurant)
        }
        
        if let result = try await currentTask?.value {
            return result
        } else {
            throw CancellationError()
        }
    }
    
    // MARK: LoadRooms
    private func loadRooms(ofRestaurant restaurant: Restaurant) async throws -> [Room] {
        try SCNetworkConnection.checkConnection()
        
        let reference = Firestore.collection(.restaurants).document(restaurant.id.unwrapWithUUID())
            .collection("rooms")
            .order(by: "name")
        
        let snapshot = try await reference.getDocuments()
        let rooms: [Room] = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Room.self)
            } catch {
                print("Failed to decode room document: \(document.documentID). Error: \(error.localizedDescription)")
                return nil
            }
        }
        
        return rooms
    }
}
