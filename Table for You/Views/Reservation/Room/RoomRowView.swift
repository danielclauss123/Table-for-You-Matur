import SwiftUI

struct RoomRowView: View {
    let room: Room
    
    @ObservedObject var viewModel: ReservationViewModel
    @ObservedObject var reservationRepository: ReservationRepository
    
    // MARK: - Body
    var body: some View {
        NavigationLink(destination: RoomView(room: room, viewModel: viewModel, reservationRepository: reservationRepository)) {
            VStack(alignment: .leading) {
                Text(room.name)
                    .font(.title2.bold())
                Text("\(room.tables.count) \(room.tables.count == 1 ? "Tisch" : "Tische")")
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
                RoomRowView(room: Room.examples[0], viewModel: .init(restaurant: .examples[0]), reservationRepository: .example)
            }
        }
    }
}
