import Foundation
import Combine
import CoreLocation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class TestRestaurantRepo: ObservableObject {
    @Published private var restaurants = [Restaurant]()
    
    init() { }
}

extension TestRestaurantRepo {
    enum LoadingStatus {
        case ready, loading, firestoreError(String), yelpError(String)
    }
}

private actor LoadingService {
    var currentTask: Task<Response, Error>?
    
    func restaurants() async throws -> Response {
        // Cancels any current task to prevent an older task finishing after a newer task.
        currentTask?.cancel()
        
        currentTask = Task {
            try await loadRestaurants()
        }
        
        if let result = try await currentTask?.value {
            return result
        } else {
            throw CancellationError()
        }
    }
    
    private func loadRestaurants() async throws -> Response {
        let reference = Firestore.collection(.restaurants)
        
        let snapshot = try await reference.getDocuments()
        let restaurants: [Restaurant] = snapshot.documents.compactMap { document in
            do {
                return try document.data(as: Restaurant.self)
            } catch {
                print("Failed to decode restaurant document \(document.documentID). Error: \(error.localizedDescription)")
                return nil
            }
        }
        
        let yelpRestaurants = await YelpRestaurantStore.shared.loadRestaurants(withIds: restaurants.map { $0.yelpId })
        
        return Response(firestore: restaurants, yelp: yelpRestaurants)
    }
    
    struct Response {
        let firestore: [Restaurant]
        let yelp: [YelpRestaurantDetail]
    }
}
