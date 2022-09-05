import SwiftUI

struct ContentView: View {
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
