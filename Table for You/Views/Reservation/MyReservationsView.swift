import SwiftUI

struct MyReservationsView: View {
    @StateObject var myReservationsRepo = MyReservationRepo()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(myReservationsRepo.reservations) { reservation in
                    ReservationRowView(reservation: reservation, restaurant: myReservationsRepo.yelpRestaurants.first(where: { $0.id == reservation.yelpId }) ?? .empty)
                }
            }
            .navigationTitle("Meine Reservationen")
        }
    }
}

struct MyReservationsView_Previews: PreviewProvider {
    static var previews: some View {
        MyReservationsView()
    }
}
