import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var userReservationsRepo = UserReservationsRepo.shared
    
    var body: some View {
        TabView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    RestaurantSearchView()
                    
                    VStack(spacing: 0) {
                        Divider()
                        
                        Rectangle().fill(.regularMaterial)
                    }
                    .frame(height: geometry.safeAreaInsets.bottom)
                }
                .ignoresSafeArea(edges: .bottom)
            }
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
