import SwiftUI
import MapKit

struct ContentView: View {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
