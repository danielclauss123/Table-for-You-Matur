import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class MyReservationRepo: ObservableObject {
    @Published var reservations = [Reservation]()
    @Published var yelpRestaurants = [YelpRestaurantDetail]()
    
    @Published private(set) var loadingStatus = LoadingStatus.ready
    
    private var currentListener: ListenerRegistration?
    private var currentListenerId: UUID?
    
    private let yelpLoadingService = YelpLoadingService()
    
    // MARK: - Init
    init() {
        addFirestoreListener()
    }
    
    // MARK: - Add Firestore Listener
    func addFirestoreListener() {
        loadingStatus = .loading
        reservations = []
        currentListener?.remove()
        
        let listenerId = UUID()
        self.currentListenerId = listenerId
        
        guard let userId = Auth.currentUser()?.uid else {
            print("The user is not logged in.")
            self.loadingStatus = .firestoreError("Not logged in.")
            return
        }
        
        currentListener = Firestore.collection(.reservations)
            .whereField("customerId", isEqualTo: userId)
            .whereField("date", isGreaterThan: Timestamp(date: Date.now.addingTimeInterval(-60 * 60 * 2)))
            .order(by: "date")
            .addSnapshotListener { snapshot, error in
                guard self.currentListenerId == listenerId else {
                    print("Different listener that gets executed then the current one.")
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("Failed to load reservations from firebase: \(error?.localizedDescription ?? "Snapshot is nil.")")
                    self.loadingStatus = .firestoreError(error?.localizedDescription ?? "Unknown Error")
                    return
                }
                
                self.reservations = snapshot.documents.compactMap { document in
                    do {
                        return try document.data(as: Reservation.self)
                    } catch {
                        print("Failed to decode document: \(error.localizedDescription)")
                        
                        return nil
                    }
                }
                
                Task { // TODO: If one yelp restaurant is fraud, not all should fail.
                    do {
                        let yelpRestaurants = try await self.yelpLoadingService.loadRestaurants(withIds: self.reservations.map { $0.yelpId })
                        
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
}

// MARK: - Example
extension MyReservationRepo {
    static let example = ReservationRepo(restaurant: .example, reservationVM: .example)
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
