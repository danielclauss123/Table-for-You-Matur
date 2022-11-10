import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class RoomReservationsRepo: ObservableObject {
    @Published private(set) var reservations = [Reservation]()
    
    @Published private(set) var loadingStatus = Firestore.LoadingStatus.ready
    
    let reservationVM: NewReservationVM
    private var dateCancellable: AnyCancellable?
    
    private var currentListener: ListenerRegistration?
    private var currentListenerId: UUID?
    
    // MARK: Init
    init(reservationVM: NewReservationVM) {
        self.reservationVM = reservationVM
        
        dateCancellable = reservationVM.$date.sink { date in
            self.addListener(forDate: date)
        }
    }
    
    // MARK: Deinit
    deinit {
        currentListener?.remove()
    }
    
    // MARK: Add Listener
    private func addListener(forDate date: Date) {
        loadingStatus = .loading
        reservations = []
        currentListener?.remove()
        
        let listenerId = UUID()
        currentListenerId = listenerId
        
        let reference = Firestore.collection(.reservations)
            .whereField("restaurantId", isEqualTo: reservationVM.restaurant.id.unwrapWithUUID())
            .whereField("date", isGreaterThan: Timestamp(date: date.addingTimeInterval(-60 * 60 * 2)))
            .whereField("date", isLessThan: Timestamp(date: date.addingTimeInterval(60 * 60 * 2)))
        
        currentListener = reference.addSnapshotListener { snapshot, error in
            guard self.currentListenerId == listenerId else {
                print("There is a newer listener than the current one. This one gets ignored.")
                return
            }
            
            guard let snapshot = snapshot else {
                self.loadingStatus = .error("Fehler beim laden.")
                
                print("Failed to load reservations of restaurant \(self.reservationVM.restaurant.id ?? "Nil") of date: \(date). Error: \(error?.localizedDescription ?? "Unknown Error.")")
                return
            }
            
            self.reservations = snapshot.documents.compactMap { document in
                do {
                    return try document.data(as: Reservation.self)
                } catch {
                    print("Failed to decode reservation document \(document.documentID). Error: \(error.localizedDescription)")
                    return nil
                }
            }
            
            self.loadingStatus = .ready
        }
    }
    
    // MARK: Functions
    func reservations(forRoomId roomId: String?) -> [Reservation] {
        reservations.filter { $0.roomId == roomId }
    }
    
    // MARK: Example
    static let example = RoomReservationsRepo(reservationVM: .example)
}
