import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class MyReservationRepo: ObservableObject {
    @Published var reservations = [Reservation]()
    
    @Published private(set) var loadingStatus = LoadingStatus.ready
    
    private var currentListener: ListenerRegistration?
    private var currentListenerId: UUID?
    
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
                
                self.loadingStatus = .ready
            }
    }
    
    // MARK: - Loading Status
    enum LoadingStatus {
        case ready, loading, firestoreError(String)
    }
}

// MARK: - Example
extension MyReservationRepo {
    static let example = ReservationRepo(restaurant: .example, reservationVM: .example)
}
