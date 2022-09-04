/*
 Note: Without the .zIndex(1) modifier, the remove transition doesn't show.
    Solution from: https://sarunw.com/posts/how-to-fix-zstack-transition-animation-in-swiftui/
 */

import SwiftUI
import CoreLocation

struct RestaurantSearchView: View {
    @StateObject var restaurantRepo: RestaurantRepo
    
    @State private var selectedRestaurant: YelpRestaurantDetail?
    
    @State private var mapCenter: CLLocationCoordinate2D?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                RestaurantAnnotationsMapView(selectedRestaurant: $selectedRestaurant, restaurants: restaurantRepo.searchedRestaurants, center: mapCenter)
                    .ignoresSafeArea()
                
                RestaurantSearchSheet(selectedRestaurant: $selectedRestaurant, restaurantRepo: restaurantRepo)
                    .zIndex(selectedRestaurant == nil ? 1 : 0) // TODO: This makes the animation not as nice, so maybe find different solution.
                
                YelpRestaurantDetailSheet(selectedRestaurant: $selectedRestaurant, restaurantRepo: restaurantRepo)
            }
            .navigationTitle("Restaurant Suche")
            .navigationBarHidden(true)
            .task {
                restaurantRepo.locationSearcher.locationSourceSelected = {
                    mapCenter = $0
                }
            }
        }
    }
    
    // MARK: - Initializer
    init() {
        self._restaurantRepo = StateObject(wrappedValue: RestaurantRepo(locationSearcher: LocationSearcher()))
    }
}


// MARK: - Previews
struct RestaurantSearchView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantSearchView()
    }
}
