import SwiftUI

struct RoomView: View {
    let room: Room
    let currentReservations: [Reservation]
    
    @ObservedObject var viewModel: ReservationViewModel
    
    @State private var scale = 1.0
    @State private var minimumScale = 0.2
    
    @State private var tableIsSelected = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    ZStack {
                        ForEach(room.tables) { table in
                            Button {
                                viewModel.roomId = room.id.unwrapWithUUID()
                                viewModel.tableId = table.id
                                
                                tableIsSelected = true
                            } label: {
                                TableView(table: table, seatFill: Color.accentColor, tableFill: Color.accentColor)
                            }
                            .disabled(!table.available(withExistingReservations: currentReservations))
                            .disabled(!table.available(forPeople: viewModel.numberOfPeople))
                            .opacity(table.available(forPeople: viewModel.numberOfPeople) ? 1 : 0.5)
                            .offset(table.offset)
                            .scaleEffect(scale)
                        }
                    }
                    .frame(width: room.size.width * scale, height: room.size.height * scale)
                }
                .magnificationGesture(scale: $scale, maximumScale: 5, minimumScale: minimumScale)
                .task {
                    scale = room.perfectScale(inGeometry: geometry)
                    minimumScale = scale
                }
            }
            
            if tableIsSelected {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        tableIsSelected = false
                    }
                
                ReservationConfirmationView(viewModel: viewModel)
            }
        }
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Previews
struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoomView(room: .examples[0], currentReservations: [], viewModel: .example)
        }
    }
}
