import SwiftUI

struct RestaurantDetailSheet: View {
    @Binding var selectedRestaurant: YelpRestaurantDetail?
    
    @ObservedObject var restaurantRepo: RestaurantRepo
    
    @State private var sheetStatus = BottomSheetStatus.hidden
    @State private var distance: Double?
    
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
        ScrollView {
            ScrollViewReader { proxy in
                PhotosView(photoURLs: restaurant.photos ?? [])
                
                OverviewRowView(restaurant: restaurant, distance: distance) { type in
                    withAnimation {
                        proxy.scrollTo(type)
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    ReserveButton(yelpRestaurant: restaurant, restaurant: restaurantRepo.restaurant(forYelpId: restaurant.id))
                    
                    if let openingHours = restaurant.openingHours {
                        InsetScrollViewSection(title: "Öffnungszeiten") {
                            OpeningHoursView(openingHours: openingHours)
                        }
                        .id(OverviewRowView.InformationType.openingHours)
                    }
                    
                    if let rating = restaurant.rating, let reviewCount = restaurant.reviewCount {
                        RatingView(rating: rating, reviewCount: reviewCount, yelpURL: restaurant.yelpURL)
                            .id(OverviewRowView.InformationType.rating)
                    }
                    
                    MapAndAddressView(restaurant: restaurant, distance: $distance)
                        .id(OverviewRowView.InformationType.distance)
                    
                    if let displayPhone = restaurant.displayPhone, let phone = restaurant.phone {
                        ContactView(phone: phone, displayPhone: displayPhone)
                    }
                    
                    CreditView(yelpURL: restaurant.yelpURL)
                }
                .padding([.horizontal, .bottom])
            }
        }
    }
}

// MARK: - Previews
struct RestaurantDetailSheet_Previews: PreviewProvider {
    struct Container: View {
        @State private var selectedRestaurant: YelpRestaurantDetail?
        
        var body: some View {
            ZStack {
                Color.brown
                    .ignoresSafeArea()
                
                RestaurantDetailSheet(selectedRestaurant: $selectedRestaurant, restaurantRepo: RestaurantRepo(locationSearcher: .example))
            }
            .task {
                selectedRestaurant = .fullExample1
            }
        }
    }
    
    static var previews: some View {
        Container()
    }
}
