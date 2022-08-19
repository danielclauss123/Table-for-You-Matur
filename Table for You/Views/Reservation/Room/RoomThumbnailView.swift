import SwiftUI

struct RoomThumbnailView: View {
    let room: Room
    let currentReservations: [Reservation]
    
    @ObservedObject var viewModel: ReservationViewModel
    
    @State private var scale = 1.0
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(room.tables) { table in
                    TableView(table: table, seatFill: Color.accentColor, tableFill: Color.accentColor)
                        .disabled(!table.available(withExistingReservations: currentReservations))
                        .disabled(!table.available(forPeople: viewModel.numberOfPeople))
                        .opacity(table.available(forPeople: viewModel.numberOfPeople) ? 1 : 0.5)
                        .offset(table.offset)
                        .scaleEffect(scale)
                }
            }
            .frame(width: room.size.width * scale, height: room.size.height * scale)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .task {
                scale = room.perfectScale(inGeometry: geometry)
            }
        }
    }
}


// MARK: - Previews
struct RoomThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        RoomThumbnailView(room: .examples[0], currentReservations: [], viewModel: .example)
    }
}
