import Foundation
import Firebase
import FirebaseAuth
import SystemConfiguration
import SwiftUI

@MainActor
class NewReservationVM: ObservableObject {
    @Published var customerName = UserDefaults.standard.loadAndDecode(fromKey: .customerName, withDefault: "") {
        didSet {
            try? UserDefaults.standard.encodeAndSet(customerName, forKey: .customerName)
        }
    }
    
    @Published var numberOfPeople = 2
    @Published var date = Date.now.addingTimeInterval(60 * 5)
    
    @Published var roomId: String?
    @Published var table: Table?
    
    @Published var successfulUpload = false
    @Published var showingErrorAlert = false
    @Published var errorMessage: String?
    
    let restaurant: Restaurant
    let yelpRestaurant: YelpRestaurantDetail
    
    var reservationInfosAreValid: Bool {
        !customerName.isEmpty && numberOfPeople >= 1 && numberOfPeople <= 20 && date > Date.now
    }
    
    var reservationTimeIsPossible: Bool {
        if let openingHours = yelpRestaurant.openingHours, !openingHours.isOpenOnTime(ofDate: date) {
            return false
        } else {
            return true
        }
    }
    
    var noUserReservationOnTime: Bool {
        for reservation in UserReservationsRepo.shared.currentReservations {
            if date <= reservation.date && date.addingTimeInterval(60 * 60 * 2) >= reservation.date {
                return false
            }
            if date >= reservation.date && date <= reservation.date.addingTimeInterval(60 * 60 * 2) {
                return false
            }
        }
        return true
    }
    
    // MARK: - Init
    init(restaurant: Restaurant, yelpRestaurant: YelpRestaurantDetail) {
        self.restaurant = restaurant
        self.yelpRestaurant = yelpRestaurant
    }
    
    // MARK: - Upload Reservation
    func uploadReservation() { // TODO: überarbeiten
        errorMessage = nil
        
        guard UserReservationsRepo.shared.currentReservations.count < 3 else {
            errorMessage = "Du kannst maximal drei anstehende Reservierungen haben."
            showingErrorAlert = true
            return
        }
        
        guard !UserReservationsRepo.shared.currentReservations.contains(where: { $0.restaurantId == restaurant.id }) else {
            errorMessage = "Du kannst nur eine anstehende Reservierung pro Restaurant haben."
            showingErrorAlert = true
            return
        }
        
        guard noUserReservationOnTime else {
            errorMessage = "Du kannst nicht zwei Reservierungen zur gleichen Zeit haben."
            showingErrorAlert = true
            return
        }
        
        guard reservationInfosAreValid else {
            errorMessage = "Die eingegebenen Informationen sind falsch oder unvollständig."
            showingErrorAlert = true
            return
        }
        
        guard reservationTimeIsPossible else {
            errorMessage = "Zur eingegebenen Zeit ist keine Reservierung möglich."
            showingErrorAlert = true
            return
        }
        
        guard let roomId = roomId, let table = table else {
            errorMessage = "Kein Tisch ausgewählt. Wähle einen aus und versuche es erneut."
            showingErrorAlert = true
            return
        }
        
        guard SCNetworkConnection.isConnectedToNetwork() else {
            errorMessage = "Keine Internet Verbindung."
            showingErrorAlert = true
            return
        }
        
        do {
            let userId = try Auth.currentUser().uid

            let reservation = Reservation(customerId: userId, customerName: customerName, numberOfPeople: numberOfPeople, restaurantId: restaurant.id.unwrapWithUUID(), yelpId: yelpRestaurant.id, roomId: roomId, tableId: table.id, date: date)
            
            try SCNetworkConnection.checkConnection()
            
            try reservation.setToFirestore()
        } catch {
            print("Failed to upload reservation to firestore: \(error.localizedDescription)")
            
            errorMessage = "Hochladen der Reservierung ist fehlgeschlagen."
            showingErrorAlert = true
        }
    }
    
    enum UploadingState {
        case inProgress, successful, failed
    }
}

// MARK: - Example
extension NewReservationVM {
    static let example = NewReservationVM(restaurant: .example, yelpRestaurant: .fullExample1)
}
