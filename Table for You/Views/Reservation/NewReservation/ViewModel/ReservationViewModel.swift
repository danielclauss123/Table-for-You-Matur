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
    @Published var date = Date.now
    
    @Published private(set) var roomId: String?
    @Published private(set) var tableId: String?
    
    @Published var showingErrorAlert = false
    @Published var errorMessage: String?
    
    let restaurant: Restaurant
    
    var reservationInfosAreValid: Bool {
        !customerName.isEmpty && date > Date.now
    }
    
    var reservationIsValid: Bool {
        reservationInfosAreValid && roomId != nil && tableId != nil
    }
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
    }
    
    func selectTable(_ tableId: String, inRoom roomId: String) {
        self.roomId = roomId
        self.tableId = tableId
    }
    
    func deselectTable() {
        self.roomId = nil
        self.tableId = nil
    }
    
    func uploadReservation() {
        errorMessage = nil
        
        guard SCNetworkConnection.isConnectedToNetwork() else {
            errorMessage = "Keine Internet Verbindung."
            showingErrorAlert = true
            return
        }
        
        /*do {
            /*let userId = try Auth.currentUser().uid
            
            /*let reservation = Reservation(id: UUID().uuidString, customerId: userId, restaurantId: restaurant.id ?? UUID().uuidString, customerName: customerName, numberOfPeople: numberOfPeople, date: date)*/
            
            try SCNetworkConnection.checkConnection()
            
            //try reservation.setToFirestore()*/
        } catch {
            print("Failed to upload reservation to firestore: \(error.localizedDescription)")
            
            errorMessage = "Hochladen der Reservierung ist fehlgeschlagen."
            showingErrorAlert = true
        }*/
    }
}
