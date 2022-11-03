import SwiftUI

struct ReservationDetailView: View {
    let reservation: Reservation
    let restaurant: YelpRestaurantDetail
    
    @StateObject var viewModel: ReservationDetailVM
    
    var body: some View {
        ScrollView {
            content
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("Reservation \(restaurant.name)")
        .navigationBarTitleDisplayMode(.inline)
        .background(.regularMaterial)
    }
    
    init(reservation: Reservation, restaurant: YelpRestaurantDetail) {
        self.reservation = reservation
        self.restaurant = restaurant
        self._viewModel = StateObject(wrappedValue: ReservationDetailVM(reservation: reservation))
    }
    
    var content: some View {
        VStack {
            AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Image.defaultPlaceholder()
                    .font(.largeTitle)
                    .aspectRatio(4 / 3, contentMode: .fit)
            }
            .cornerRadius(10)
            .frame(height: 270)
            
            InsetScrollViewSection(title: "Daten") {
                HStack {
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text(reservation.date, style: .time)
                            +
                            Text(", ")
                            
                            Text(reservation.date, style: .date)
                        }
                        .bold()
                        
                        Text("**\(reservation.numberOfPeople) \(reservation.numberOfPeople == 1 ? "Person" : "Personen")**")
                        +
                        Text(" unter \(reservation.customerName)")
                    }
                    Spacer()
                }
            }
            
            InsetScrollViewSection(title: "Tisch") {
                switch viewModel.loadingStatus {
                case .loading:
                    ProgressView()
                case .error(let message):
                    Text(message)
                case .ready:
                    if let room = viewModel.room {
                        VStack(alignment: .leading) {
                            Text("\(room.name)")
                                .bold()
                            
                            RoomReservedTableView(room: room, reservedTableId: reservation.tableId)
                                .frame(height: 270)
                        }
                    } else {
                        Text("No Room")
                    }
                }
            }
            
            RestaurantDetailSheet.MapAndAddressView(restaurant: restaurant, distance: .constant(nil))
            
            if let phone = restaurant.phone, let displayPhone = restaurant.displayPhone {
                RestaurantDetailSheet.ContactView(phone: phone, displayPhone: displayPhone)
            }
            
            RestaurantDetailSheet.CreditView(yelpURL: restaurant.yelpURL)
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
