import SwiftUI

struct ReservationDetailView: View {
    let reservation: Reservation
    let restaurant: YelpRestaurantDetail
    
    @StateObject var viewModel: ReservationDetailVM
    
    var body: some View {
        ScrollView {
            switch viewModel.loadingStatus {
            case .loading:
                ProgressView()
            case .error(let message):
                Text(message)
            case .ready:
                content
            }
        }
        .navigationTitle("Reservation \(restaurant.name)")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .secondarySystemBackground).ignoresSafeArea())
    }
    
    init(reservation: Reservation, restaurant: YelpRestaurantDetail) {
        self.reservation = reservation
        self.restaurant = restaurant
        self._viewModel = StateObject(wrappedValue: ReservationDetailVM(reservation: reservation))
    }
    
    var content: some View {
        VStack {
            if let room = viewModel.room {
                InsetScrollViewSection(title: room.name) {
                    RoomReservedTableView(room: room, reservedTableId: reservation.tableId)
                        .frame(height: 300)
                }
            } else {
                Text("No Room")
            }
            
            RestaurantDetailSheet.MapAndAddressView(restaurant: restaurant, distance: .constant(nil))
        }
        .padding(.horizontal)
    }
}


// MARK: - Previews
struct ReservationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReservationDetailView(reservation: .example, restaurant: .examples[0])
        }
    }
}
