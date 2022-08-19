import SwiftUI

struct RoomRowView: View {
    let room: Room
    let currentReservations: [Reservation]
    
    @ObservedObject var viewModel: ReservationViewModel
    
    var availableTableCount: Int {
        room.availableTableCount(numberOfPeople: viewModel.numberOfPeople, existingReservations: currentReservations)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationLink(destination: RoomView(room: room, currentReservations: currentReservations, viewModel: viewModel)) {
            HStack {
                RoomThumbnailView(room: room, currentReservations: currentReservations, viewModel: viewModel)
                    .frame(width: 110, height: 110)
                
                VStack(alignment: .leading) {
                    Text(room.name)
                        .font(.headline)
                        .foregroundColor(availableTableCount != 0 ? .primary : .secondary)
                    Text("\(availableTableCount) \(availableTableCount == 1 ? "Tisch" : "Tische") verfügbar")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}


// MARK: - Previews
struct RoomRowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                RoomRowView(room: .examples[0], currentReservations: [], viewModel: .example)
            }
        }
    }
}
