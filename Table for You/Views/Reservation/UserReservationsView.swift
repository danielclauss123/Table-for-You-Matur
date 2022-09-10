import SwiftUI

struct UserReservationsView: View {
    @StateObject var viewModel = UserReservationsVM()
    
    var body: some View {
        List {
            ForEach(viewModel.currentReservations) { reservation in
                if let y = viewModel.yelpRestaurant(withId: reservation.yelpId) {
                    ReservationRowView(reservation: reservation, restaurant: y)
                }
            }
            
            ForEach(viewModel.pastReservations) { reservation in
                ReservationRowView(reservation: reservation, restaurant: viewModel.yelpRestaurant(withId: reservation.yelpId)!)
            }
        }
    }
}


// MARK: - Previews
struct UserReservationsView_Previews: PreviewProvider {
    static var previews: some View {
        UserReservationsView()
    }
}
