import Foundation
import Firebase
import FirebaseAuth
import SystemConfiguration
import SwiftUI

class ReservationVM: ObservableObject {
    @Published var customerName = UserDefaults.standard.loadAndDecode(fromKey: .customerName, withDefault: "") {
        didSet {
            try? UserDefaults.standard.encodeAndSet(customerName, forKey: .customerName)
        }
    }
    
    @Published var numberOfPeople = 2
    @Published var date = Date.now.addingTimeInterval(60 * 5)
    
    @Published var roomId: String?
    @Published var tableId: String?
    
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
    
    // MARK: - Init
    init(restaurant: Restaurant, yelpRestaurant: YelpRestaurantDetail) {
        self.restaurant = restaurant
        self.yelpRestaurant = yelpRestaurant
    }
    
    // MARK: - Upload Reservation
    func uploadReservation() { // TODO: überarbeiten
        errorMessage = nil
        
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
        
        guard let roomId = roomId, let tableId = tableId else {
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

            let reservation = Reservation(customerId: userId, customerName: customerName, restaurantId: restaurant.id.unwrapWithUUID(), roomId: roomId, tableId: tableId, date: date)
            
            try SCNetworkConnection.checkConnection()
            
            try reservation.setToFirestore()
        } catch {
            print("Failed to upload reservation to firestore: \(error.localizedDescription)")
            
            errorMessage = "Hochladen der Reservierung ist fehlgeschlagen."
            showingErrorAlert = true
        }
    }
}

// MARK: - Example
extension ReservationVM {
    static let example = ReservationVM(restaurant: .examples[0], yelpRestaurant: .fullExample1)
}
