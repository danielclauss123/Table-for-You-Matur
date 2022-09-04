import SwiftUI
import CoreLocation

struct YelpRestaurantDetailSheet: View {
    @Binding var selectedRestaurant: YelpRestaurantDetail?
    
    @ObservedObject var restaurantRepo: RestaurantRepo
    
    @State private var sheetStatus = BottomSheetStatus.hidden
    
    @State private var distance: Double?
    
    @State private var showingReservationSheet = false
    
    // MARK: - Body
    var body: some View {
        BottomSheet(sheetStatus: $sheetStatus, background: .thickMaterial) {
            header
        } content: {
            if let selectedRestaurant = selectedRestaurant {
                content(restaurant: selectedRestaurant)
            }
        }
        .navigationTitle(selectedRestaurant?.name ?? "")
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    var header: some View {
        HStack {
            Text(selectedRestaurant?.name ?? "")
                .font(.title2.bold())
            
            Spacer()
            
            Button {
                selectedRestaurant = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(7)
                    .background(.quaternary)
                    .clipShape(Circle())
            }
            .foregroundColor(.primary)
            .onChange(of: selectedRestaurant) {
                if $0 == nil {
                    sheetStatus = .hidden
                } else {
                    sheetStatus = .up
                }
            }
        }
        .padding(.bottom, 5)
    }
    
    // MARK: - Content
    func content(restaurant: YelpRestaurantDetail) -> some View {
        Text("Conentemt")
    }
}


// MARK: - Previews
struct YelpRestaurantDetailSheet_Previews: PreviewProvider {
    struct Container: View {
        @State private var selectedRestaurant: YelpRestaurantDetail?
        
        var body: some View {
            NavigationView {
                ZStack {
                    RestaurantAnnotationsMapView(selectedRestaurant: $selectedRestaurant, restaurants: YelpRestaurantDetail.examples, center: CLLocationCoordinate2D(latitude: 47, longitude: 8))
                        .ignoresSafeArea()
                    
                    YelpRestaurantDetailSheet(selectedRestaurant: $selectedRestaurant, restaurantRepo: RestaurantRepo(locationSearcher: .example))
                }
                .task {
                    selectedRestaurant = .fullExample1
                }
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
