import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class ReservationRepo: ObservableObject {
    @Published var reservations = [Reservation]()
    
    @Published private(set) var loadingStatus = LoadingStatus.ready
    
    let restaurant: Restaurant
    
    let reservationVM: ReservationVM
    private var dateCancellable: AnyCancellable?
    
    private var currentListener: ListenerRegistration?
    private var currentListenerId: UUID?
    
    // MARK: - Init
    init(restaurant: Restaurant, reservationVM: ReservationVM) {
        self.restaurant = restaurant
        self.reservationVM = reservationVM
        
        dateCancellable = reservationVM.$date.sink { date in
            self.addFirestoreListener(forDate: date)
        }
    }
    
    // MARK: - Add Firestore Listener
    func addFirestoreListener(forDate date: Date) {
        loadingStatus = .loading
        reservations = []
        currentListener?.remove()
        
        let listenerId = UUID()
        self.currentListenerId = listenerId
        
        currentListener = Firestore.collection(.reservations)
            .whereField("restaurantId", isEqualTo: restaurant.id.unwrapWithUUID())
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
    
    func reservations(forRoomId roomId: String?) -> [Reservation] {
        reservations.filter { $0.roomId == roomId }
    }
    
    // MARK: - Loading Status
    enum LoadingStatus {
        case ready, loading, firestoreError(String)
    }
}

// MARK: - Example
extension ReservationRepo {
    static let example = ReservationRepo(restaurant: .examples[0], reservationVM: .example)
}
