import SwiftUI
import MapKit

/*struct ContentView: View {
    @StateObject var userReservationsRepo = UserReservationsRepo.shared
    
    var body: some View {
        TabView {
            RestaurantSearchView()
                .tabItem {
                    Label("Suchen", systemImage: "magnifyingglass")
                }
            
            UserReservationsView()
                .tabItem {
                    Label("Reservierungen", systemImage: "calendar")
                }
        }
    }
}*/

struct ContentView: View {
    @State private var selected: YelpRestaurantDetail?
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 47, longitude: 8)
    
    var body: some View {
        VStack {
            RestaurantsMapView(selectedRestaurant: $selected, centerCoordinate: $centerCoordinate, restaurants: YelpRestaurantDetail.examples)
            
            Button("TAp") {
                centerCoordinate = .init(latitude: 50, longitude: 2)
            }
            .padding(30)
            
            Text("\(centerCoordinate.latitude)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
