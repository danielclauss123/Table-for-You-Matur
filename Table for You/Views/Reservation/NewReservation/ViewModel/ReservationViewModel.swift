import Foundation
import Firebase
import FirebaseAuth
import SystemConfiguration

class ReservationViewModel: ObservableObject {
    @Published var customerName = UserDefaults.standard.loadAndDecode(fromKey: .customerName, withDefault: "") {
        didSet {
            try? UserDefaults.standard.encodeAndSet(customerName, forKey: .customerName)
        }
    }
    
    @Published var numberOfPeople = 2
    @Published var date = Date.now.addingTimeInterval(60)
    
    @Published var roomId: String?
    @Published var tableId: String?
    
    @Published var showingErrorAlert = false
    @Published var errorMessage: String?
    
    let restaurant: Restaurant
    let yelpRestaurant: YelpRestaurantDetail
    
    var detailsAreValid: Bool {
        !customerName.isEmpty && numberOfPeople >= 1 && numberOfPeople <= 20 && date > Date.now
    }
    
    init(restaurant: Restaurant, yelpRestaurant: YelpRestaurantDetail) {
        self.restaurant = restaurant
        self.yelpRestaurant = yelpRestaurant
    }
    
    func uploadReservation() {
        errorMessage = nil
        
        guard SCNetworkConnection.isConnectedToNetwork() else {
            errorMessage = "Keine Internet Verbindung."
            showingErrorAlert = true
            return
        }
        
        guard let roomId = roomId, let tableId = tableId else {
            errorMessage = "Kein Tisch ausgewählt. Gehe zurück und wähle einen aus."
            showingErrorAlert = true
            return
        }
        
        do {
            let userId = try Auth.currentUser().uid

            let reservation = Reservation(customerId: userId, customerName: customerName, restaurantId: restaurant.uuidUnwrappedId, roomId: roomId, tableId: tableId, date: date)
            
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
extension ReservationViewModel {
    static let example = ReservationViewModel(restaurant: .examples[0], yelpRestaurant: .fullExample1)
}
