import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class ReservationRepository: ObservableObject {
    @Published var reservations = [Reservation]()
    @Published var date: Date {
        didSet {
            addFirestoreListener()
        }
    }
    
    @Published private(set) var loadingStatus = LoadingStatus.ready
    
    let restaurant: Restaurant
    
    private var currentListener: ListenerRegistration?
    private var currentListenerId: UUID?
    
    // MARK: - Init
    init(restaurant: Restaurant, date: Date) {
        self.restaurant = restaurant
        self.date = date
        
        addFirestoreListener()
    }
    
    // MARK: - Add Firestore Listener
    func addFirestoreListener() {
        loadingStatus = .loading
        reservations = []
        currentListener?.remove()
        
        let listenerId = UUID()
        self.currentListenerId = listenerId
        
        currentListener = Firestore.collection(.reservations)
            .whereField("restaurantId", isEqualTo: restaurant.uuidUnwrappedId)
            .whereField("date", isGreaterThan: Timestamp(date: date.addingTimeInterval(-60 * 60 * 2)))
            .whereField("date", isLessThan: Timestamp(date: date.addingTimeInterval(60 * 60 * 2)))
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
                
                self.loadingStatus = .ready
            }
    }
    
    // MARK: - Loading Status
    enum LoadingStatus {
        case ready, loading, firestoreError(String)
    }
}

// MARK: - Example
extension ReservationRepository {
    static let example = ReservationRepository(restaurant: .examples[0], date: Date.now)
}
