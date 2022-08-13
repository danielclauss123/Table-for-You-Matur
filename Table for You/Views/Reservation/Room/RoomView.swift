import SwiftUI

struct RoomView: View {
    let room: Room
    
    @ObservedObject var viewModel: ReservationViewModel
    @ObservedObject var reservationRepository: ReservationRepository
    
    @State private var scale = 1.0
    @State private var tableIsSelected = false
    
    // MARK: - Body
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    ZStack {
                        ForEach(room.tables) { table in
                            Button {
                                viewModel.roomId = room.id.unwrapWithUUID()
                                viewModel.tableId = table.id
                                
                                tableIsSelected = true
                            } label: {
                                TableView(table: table)
                            }
                            .disabled((reservationRepository.reservations.first(where: { $0.tableId == table.id }) != nil))
                            .overlay((reservationRepository.reservations.first(where: { $0.tableId == table.id }) != nil) ? Color.red : Color.clear)
                            .offset(table.offset)
                            .scaleEffect(scale)
                        }
                        
                        NavigationLink(isActive: $tableIsSelected) {
                            ReservationConfirmationView(viewModel: viewModel)
                        } label: {
                            EmptyView()
                        }

                    }
                    .frame(width: room.size.width * scale, height: room.size.height * scale)
                }
                .magnificationGesture(scale: $scale, maximumScale: 5, minimumScale: 0.2)
                .task {
                    scale = room.perfectScale(inGeometry: geometry)
                }
            }
            
            DatePicker("Datum und Zeit", selection: $viewModel.date, displayedComponents: [.date, .hourAndMinute])
                .padding()
                .background(.regularMaterial)
                .disabled(true)
            // Funktioniert noch nicht weil keine Verbindung zwischen ViewModel und Repository...
            
        }
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Previews
struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoomView(room: .examples[0], viewModel: .init(restaurant: .examples[0]), reservationRepository: .example)
        }
    }
}
