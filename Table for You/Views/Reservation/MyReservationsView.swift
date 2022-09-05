import SwiftUI

struct MyReservationsView: View {
    @StateObject var myReservationsRepo = MyReservationRepo()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(myReservationsRepo.reservations) { reservation in
                    VStack {
                        Text(reservation.customerName)
                        Text(reservation.date, style: .date)
                        Text(reservation.date, style: .time)
                    }
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
