import SwiftUI
import CoreLocation

struct RestaurantSearchSheet: View {
    @Binding var selectedRestaurant: YelpRestaurantDetail?
    
    @ObservedObject var restaurantRepository: RestaurantRepository
    @ObservedObject var locationSearcher: LocationSearcher
    
    @State private var sheetStatus = BottomSheetStatus.up
    
    @FocusState private var restaurantSearchIsFocused: Bool
    
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
                    systemImage: "magnifyingglass",
                    backgroundColor: Color(uiColor: .systemGray5),
                    text: $restaurantRepository.searchText
                ) { isEditing in
                    if isEditing {
                        sheetStatus = .up
                    }
                }
                .focused($restaurantSearchIsFocused)
                .onSubmit {
                    sheetStatus = .middle
                }
                .onChange(of: sheetStatus) { newValue in
                    if newValue == .middle || newValue == .down {
                        restaurantSearchIsFocused = false
                    }
                }
                
                if restaurantSearchIsFocused {
                    Button("Abbrechen") {
                        sheetStatus = .middle
                        restaurantRepository.searchText = ""
                    }
                    .transition(.opacity)
                }
            }
            
            HStack {
                LocationSearchButton(locationSearcher: locationSearcher) {
                    sheetStatus = .middle
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Content
    var content: some View {
        Group {
            switch restaurantRepository.loadingStatus {
                case .loading:
                    ProgressView()
                        .frame(maxHeight: .infinity)
                case .yelpError(let error):
                    errorView(error)
                case .firestoreError(let error):
                    errorView(error)
                case .ready:
                    if restaurantRepository.searchedRestaurants.isEmpty {
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
        Text(error)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .frame(maxHeight: .infinity)
    }
    
    // MARK: - Restaurant List
    var restaurantList: some View {
        ScrollView {
            VStack {
                ForEach(restaurantRepository.searchedRestaurants) { restaurant in
                    YelpRestaurantDetailRowView(restaurant: restaurant) {
                        selectedRestaurant = restaurant
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Initializer
    init(selectedRestaurant: Binding<YelpRestaurantDetail?>, restaurantRepository: RestaurantRepository) {
        self._selectedRestaurant = selectedRestaurant
        self.restaurantRepository = restaurantRepository
        self.locationSearcher = restaurantRepository.locationSearcher
    }
}


// MARK: - Previews
struct RestaurantSearchSheet_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            ZStack {
                RestaurantAnnotationsMapView(selectedRestaurant: .constant(nil), restaurants: [], center: .zero)
                    .ignoresSafeArea()
                
                RestaurantSearchSheet(selectedRestaurant: .constant(nil), restaurantRepository: RestaurantRepository(locationSearcher: LocationSearcher.example))
            }
        }
        .tabItem {
            Label("Trash", systemImage: "trash")
        }
    }
}
