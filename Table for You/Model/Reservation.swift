import Foundation
import FirebaseFirestoreSwift

// MARK: - Struct
struct Reservation: Identifiable, Codable {
    @DocumentID var id: String?
    
    var customerId: String
    var customerName: String
    
    var restaurantId: String
    var roomId: String
    var tableId: String
    
    var date: Date
}

// MARK: - Computed Properties
extension Reservation {
    /// The id unwrapped with a uuid default.
    var uuidUnwrappedId: String {
        id ?? UUID().uuidString
    }
    
    var endDate: Date {
        date.addingTimeInterval(60 * 60 * 2)
    }
}
