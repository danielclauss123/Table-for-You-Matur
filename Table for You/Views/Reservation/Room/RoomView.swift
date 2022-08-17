import SwiftUI

struct RoomView: View {
    let room: Room
    
    @ObservedObject var viewModel: ReservationViewModel
    @ObservedObject var reservationRepository: ReservationRepository
    
    @State private var scale = 1.0
    @State private var minimumScale = 0.2
    
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
                                TableView(table: table, seatFill: Color.accentColor, tableFill: Color.accentColor)
                            }
                            .disabled((reservationRepository.reservations.first(where: { $0.tableId == table.id }) != nil))
                            .disabled(table.seats.count + 2 < viewModel.numberOfPeople || table.seats.count - 2 > viewModel.numberOfPeople)
                            .opacity(table.seats.count + 2 < viewModel.numberOfPeople || table.seats.count - 2 > viewModel.numberOfPeople ? 0.5 : 1)
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
                .magnificationGesture(scale: $scale, maximumScale: 5, minimumScale: minimumScale)
                .task {
                    scale = room.perfectScale(inGeometry: geometry)
                    minimumScale = scale
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
