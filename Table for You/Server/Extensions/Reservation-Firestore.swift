import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension Reservation {
    var firestoreReference: DocumentReference {
        Firestore.collection(.reservations).document(id.unwrapWithUUID())
    }
    
    func setToFirestore() throws {
        try firestoreReference.setData(from: self)
    }
    
    func deleteFromFirestore() async throws {
        try await firestoreReference.delete()
    }
}
