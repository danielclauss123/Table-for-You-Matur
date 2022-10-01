/*
 Note: Without the .zIndex(1) modifier, the remove transition doesn't show.
    Solution from: https://sarunw.com/posts/how-to-fix-zstack-transition-animation-in-swiftui/
 */

import SwiftUI
import CoreLocation

struct RestaurantSearchView: View {
    @StateObject var restaurantRepo: RestaurantRepo
    
    @State private var selectedRestaurant: YelpRestaurantDetail?
    
    @State private var mapCenter = CLLocationCoordinate2D()
    @State private var lastSetSource = LocationSearcher.LocationSource.undefined
    
    @State private var locationWillChange = false
    
    @StateObject var locationSearcher: LocationSearcher
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                RestaurantsMapView(selectedRestaurant: $selectedRestaurant, centerCoordinate: $mapCenter, restaurants: restaurantRepo.searchedRestaurants)
                    .ignoresSafeArea()
                
                RestaurantSearchSheet(selectedRestaurant: $selectedRestaurant, restaurantRepo: restaurantRepo)
                    .zIndex(selectedRestaurant == nil ? 1 : 0) // TODO: This makes the animation not as nice, so maybe find different solution.
                
                RestaurantDetailSheet(selectedRestaurant: $selectedRestaurant, restaurantRepo: restaurantRepo)
            }
            .navigationTitle("Restaurant Suche")
            .navigationBarHidden(true)
            /*.onReceive(restaurantRepo.locationSearcher.$locationSource, perform: { _ in
                locationWillChange = true
            })*/
            /*.onChange(of: restaurantRepo.locationSearcher.locationSource) { source in
                if source != .undefined {
                    locationWillChange = true
                }
            }*/
            .onChange(of: locationSearcher.coordinate) { coordinate in
                guard let coordinate = coordinate else { return }
                print("asdfkasdljhfas kdlfghasjkdflad adhsfkjsadhf jkalsfd fafkasdfahdklsfjahdjsfas")
                
                if locationSearcher.aboutToChange {
                    mapCenter = coordinate
                    locationWillChange = false
                    locationSearcher.aboutToChange = false
                }
            }
            /*.onChange(of: restaurantRepo.locationSearcher.coordinate) { coordinate in
                guard lastSetSource != restaurantRepo.locationSearcher.locationSource else { return }
                
                guard let coordinate = coordinate else { return }
                
                mapCenter = coordinate
                lastSetSource = restaurantRepo.locationSearcher.locationSource
            }*/
        }
    }
    
    // MARK: - Initializer
    init() {
        let locationSearcher = LocationSearcher()
        
        self._locationSearcher = StateObject(wrappedValue: locationSearcher)
        self._restaurantRepo = StateObject(wrappedValue: RestaurantRepo(locationSearcher: locationSearcher))
    }
}


// MARK: - Previews
struct RestaurantSearchView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantSearchView()
    }
}
