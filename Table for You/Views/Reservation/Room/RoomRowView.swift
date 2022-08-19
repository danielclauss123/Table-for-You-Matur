import SwiftUI

struct RoomRowView: View {
    let room: Room
    let currentReservations: [Reservation]
    
    @ObservedObject var viewModel: ReservationViewModel
    @ObservedObject var reservationRepository: ReservationRepository
    
    var availableTableCount: Int {
        room.availableTableCount(numberOfPeople: viewModel.numberOfPeople, existingReservations: currentReservations)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationLink(destination: RoomView(room: room, viewModel: viewModel, reservationRepository: reservationRepository)) {
            VStack(alignment: .leading) {
                Text(room.name)
                    .font(.headline)
                Text("\(availableTableCount) \(availableTableCount == 1 ? "Tisch" : "Tische") verfügbar")
                    .foregroundColor(.secondary)
            }
        }
    }
}


// MARK: - Previews
struct RoomRowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                RoomRowView(room: Room.examples[0], currentReservations: [], viewModel: .example, reservationRepository: .example)
            }
        }
    }
}
