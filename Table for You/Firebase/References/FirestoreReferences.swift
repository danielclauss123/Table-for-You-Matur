/*
 Abstract:
    Reference zu Firestore.
*/

import Foundation
import FirebaseFirestore

extension Firestore {
    /// A reference to one of the main collections in Firestore.
    static func collection(_ collection: FirestoreCollection) -> CollectionReference {
        firestore().collection(collection.rawValue)
    }
}

/// The main collections in Firestore.
enum FirestoreCollection: String {
    case restaurants
}
