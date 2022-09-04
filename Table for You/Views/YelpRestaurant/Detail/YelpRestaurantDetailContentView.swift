import SwiftUI

struct YelpRestaurantDetailContentView: View {
    var restaurant: YelpRestaurantDetail
    var reservable: Bool = true
    
    @ObservedObject var restaurantRepo: RestaurantRepo
    
    @State private var distance: Double?
    @State private var showingReservationSheet = false
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                PhotosView(photoURLs: restaurant.photos ?? [])
                
                OverviewRowView(restaurant: restaurant, distance: distance) { type in
                    withAnimation {
                        proxy.scrollTo(type)
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    Button {
                        showingReservationSheet = true
                    } label: {
                        Label("Reservieren", systemImage: "calendar.badge.plus")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $showingReservationSheet) {
                        if let firestoreRestaurant = restaurantRepo.restaurant(forYelpId: restaurant.id) {
                            NewReservationView(restaurant: firestoreRestaurant, yelpRestaurant: restaurant, sheetIsPresented: $showingReservationSheet)
                        }
                    }
                    
                    if let openingHours = restaurant.openingHours {
                        InsetScrollViewSection(title: "Öffnungszeiten") {
                            OpeningHoursView(openingHours: openingHours)
                        }
                        .id(OverviewRowView.InformationType.openingHours)
                    }
                    
                    if let rating = restaurant.rating, let reviewCount = restaurant.reviewCount {
                        ReviewView(rating: rating, reviewCount: reviewCount, yelpURL: restaurant.yelpURL)
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
struct YelpRestaurantDetailContentView_Previews: PreviewProvider {
    static var previews: some View {
        YelpRestaurantDetailContentView(restaurant: .fullExample1, restaurantRepo: .init(locationSearcher: .example))
    }
}
