import SwiftUI
import CoreLocation

struct RestaurantSearchSheet: View {
    @Binding var selectedRestaurant: YelpRestaurantDetail?
    
    @ObservedObject var restaurantRepo: RestaurantRepo
    @ObservedObject var locationSearcher: LocationSearcher
    
    var mapCenter: CLLocationCoordinate2D
    
    @State private var sheetStatus = BottomSheetStatus.middle
    
    @FocusState private var restaurantSearchIsFocused: Bool
    
    var showingMapAreaButton: Bool {
        guard let coordinate = locationSearcher.coordinate else { return false }
        
        return coordinate.distance(from: mapCenter) > 50 * 1000
    }
    
    // MARK: - Body
    var body: some View {
        BottomSheet(sheetStatus: $sheetStatus, background: .thickMaterial) {
            header
        } content: {
            content
        }
        .onChange(of: selectedRestaurant) {
            if $0 == nil {
                sheetStatus = .middle
            } else {
                restaurantSearchIsFocused = false
                sheetStatus = .hidden
            }
        }
    }
    
    // MARK: - Header
    var header: some View {
        VStack {
            HStack {
                SearchField(
                    "Restaurant Name",
                    text: $restaurantRepo.searchText, systemImage: "magnifyingglass",
                    backgroundColor: Color(uiColor: .systemGray5)
                )
                .focused($restaurantSearchIsFocused)
                .onSubmit {
                    sheetStatus = .middle
                }
                .onChange(of: restaurantSearchIsFocused) {
                    if $0 {
                        sheetStatus = .up
                    }
                }
                .onChange(of: sheetStatus) { newValue in
                    if newValue == .middle || newValue == .down {
                        restaurantSearchIsFocused = false
                    }
                }
                
                if restaurantSearchIsFocused {
                    Button("Abbrechen") {
                        sheetStatus = .middle
                        restaurantRepo.searchText = ""
                    }
                    .transition(.opacity)
                }
            }
            
            HStack(spacing: 0) {
                LocationSearchButton(locationSearcher: locationSearcher, mapCenter: mapCenter) {
                    sheetStatus = .middle
                }
                
                Spacer()
                
                if showingMapAreaButton {
                    Button {
                        locationSearcher.selectMapCoordinate(mapCenter)
                    } label: {
                        HStack {
                            Text("Hier Suchen")
                                .font(.subheadline.bold())
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    // MARK: - Content
    var content: some View {
        Group {
            switch restaurantRepo.loadingStatus {
            case .loading:
                ProgressView()
                    .frame(maxHeight: .infinity)
            case .error(let message):
                errorView(message)
            case .ready:
                if restaurantRepo.searchedRestaurants.isEmpty {
                    Text("Kein Ergebnis.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity)
                } else {
                    restaurantList
                }
            }
        }
    }
    
    // MARK: - Error View
    func errorView(_ error: String) -> some View {
        VStack {
            Text(error)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button {
                restaurantRepo.loadRestaurants()
            } label: {
                Label("Nochmal versuchen", systemImage: "arrow.counterclockwise")
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Restaurant List
    var restaurantList: some View {
        ScrollView {
            VStack {
                ForEach(restaurantRepo.searchedRestaurants) { restaurant in
                    RestaurantRowView(restaurant: restaurant) {
                        selectedRestaurant = restaurant
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Initializer
    init(selectedRestaurant: Binding<YelpRestaurantDetail?>, restaurantRepo: RestaurantRepo, mapCenter: CLLocationCoordinate2D) {
        self._selectedRestaurant = selectedRestaurant
        self.restaurantRepo = restaurantRepo
        self.locationSearcher = restaurantRepo.locationSearcher
        self.mapCenter = mapCenter
    }
}


// MARK: - Previews
struct RestaurantSearchSheet_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            ZStack {
                Color.brown
                    .ignoresSafeArea()
                
                RestaurantSearchSheet(selectedRestaurant: .constant(nil), restaurantRepo: RestaurantRepo(locationSearcher: LocationSearcher.example), mapCenter: .zero)
            }
        }
        .tabItem {
            Label("Trash", systemImage: "trash")
        }
    }
}
