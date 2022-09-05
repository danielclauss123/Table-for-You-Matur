import SwiftUI

extension RestaurantDetailSheet {
    struct ReserveButton: View {
        let yelpRestaurant: YelpRestaurantDetail
        let restaurant: Restaurant?
        
        @State private var showingReservationSheet = false
        
        // MARK: - Body
        var body: some View {
            Button {
                showingReservationSheet = true
            } label: {
                Label("Reservieren", systemImage: "calendar.badge.plus")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(restaurant == nil)
            .sheet(isPresented: $showingReservationSheet) {
                if let restaurant = restaurant {
                    NewReservationView(restaurant: restaurant, yelpRestaurant: yelpRestaurant, sheetIsPresented: $showingReservationSheet)
                }
            }
        }
    }
}


// MARK: - Previews
struct ReserveButton_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailSheet.ReserveButton(yelpRestaurant: .fullExample1, restaurant: .example)
            .previewLayout(.sizeThatFits)
    }
}
