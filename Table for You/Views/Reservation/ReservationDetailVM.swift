import Foundation
import SystemConfiguration
import FirebaseFirestore

@MainActor
class ReservationDetailVM: ObservableObject {
    @Published private(set) var room: Room?
    @Published private(set) var loadingStatus = Firestore.LoadingStatus.ready
    
    let reservation: Reservation
    
    private let loadingService = LoadingService()
    
    // MARK: Init
    init(reservation: Reservation) {
        self.reservation = reservation
        
        loadRoom()
    }
    
    // MARK: Example Init
    init(reservation: Reservation, room: Room) {
        self.reservation = reservation
        self.room = room
    }
    
    private func loadRoom() {
        loadingStatus = .loading
        
        Task {
            do {
                self.room = try await self.loadingService.room(fromReservation: reservation)
                loadingStatus = .ready
            } catch is CancellationError {
                print("Loading room task got canceled.")
            } catch SCNetworkConnection.NetworkConnectionError.noConnection {
                self.loadingStatus = .error("Keine Internetverbindung")
                print("No network connection.")
            } catch {
                self.loadingStatus = .error("Fehler beim laden")
                print("Failed to load room \(reservation.roomId). Error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Loading Service
private actor LoadingService {
    var currentTask: Task<Room, Error>?
    
    // MARK: Room
    /// The room of a given reservation.
    func room(fromReservation reservation: Reservation) async throws -> Room {
        // Cancels any current task to prevent an older task finishing after a newer task.
        currentTask?.cancel()
        
        currentTask = Task {
            try await loadRoom(fromReservation: reservation)
        }
        
        if let result = try await currentTask?.value {
            return result
        } else {
            throw CancellationError()
        }
    }
    
    // MARK: Load Room
    private func loadRoom(fromReservation reservation: Reservation) async throws -> Room {
        try SCNetworkConnection.checkConnection()
        
        let reference = Firestore.collection(.restaurants).document(reservation.restaurantId)
            .collection("rooms")
            .document(reservation.roomId)
        
        let snapshot = try await reference.getDocument()
        
        return try snapshot.data(as: Room.self)
    }
}
