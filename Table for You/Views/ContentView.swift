import SwiftUI

struct ContentView: View {
    @StateObject var userReservationsRepo = UserReservationsRepo.shared
    
    var body: some View {
        TabView {
            MyReservationsView()
                .tabItem {
                    Label("Reservierungen", systemImage: "calendar")
                }
            
            RestaurantSearchView()
                .tabItem {
                    Label("Suchen", systemImage: "magnifyingglass")
                }
            
            UserReservationsView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
