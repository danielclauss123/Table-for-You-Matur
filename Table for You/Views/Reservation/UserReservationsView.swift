import SwiftUI

struct UserReservationsView: View {
    @StateObject var viewModel = UserReservationsVM()
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.pastReservations.isEmpty && viewModel.currentReservations.isEmpty {
                    Text("Mache deine erste Reservierung...")
                }
                
                if !viewModel.currentReservations.isEmpty {
                    Section("Anstehende") {
                        ForEach(viewModel.currentReservations) { reservation in
                            ReservationRowView(reservation: reservation, restaurant: viewModel.yelpRestaurant(withId: reservation.yelpId))
                        }
                    }
                }
                
                if !viewModel.pastReservations.isEmpty {
                    Section("Bisherige") {
                        ForEach(viewModel.pastReservations) { reservation in
                            ReservationRowView(reservation: reservation, restaurant: viewModel.yelpRestaurant(withId: reservation.yelpId))
                        }
                    }
                }
            }
            .navigationTitle("Reservierungen")
        }
    }
}


// MARK: - Previews
struct UserReservationsView_Previews: PreviewProvider {
    static var previews: some View {
        UserReservationsView()
    }
}
