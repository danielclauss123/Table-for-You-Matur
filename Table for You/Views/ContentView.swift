import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
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
