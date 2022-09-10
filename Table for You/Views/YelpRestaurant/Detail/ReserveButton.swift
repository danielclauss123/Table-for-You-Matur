import SwiftUI

extension RestaurantDetailSheet {
    struct ReserveButton: View {
        let yelpRestaurant: YelpRestaurantDetail
        let restaurant: Restaurant?
        
        @State private var showingReservationSheet = false
        
        @MainActor
        var problem: String? {
            if UserReservationsRepo.shared.currentReservations.count >= 3 {
                return "Du kannst höchstens drei anstehende Reservierungen haben."
            } else if !UserReservationsRepo.shared.currentReservations.contains(where: { $0.yelpId == yelpRestaurant.id }) {
                return "Du kannst nur eine anstehende Reservierung pro Restaurant haben."
            }
            
            return nil
        }
        
        // MARK: - Body
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Button {
                    showingReservationSheet = true
                } label: {
                    Label("Reservieren", systemImage: "calendar.badge.plus")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(restaurant == nil || problem != nil)
                
                if let problem = problem {
                    Text(problem)
                        .font(.footnote)
                }
                
            }
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
