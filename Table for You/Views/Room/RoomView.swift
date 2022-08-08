import SwiftUI

struct RoomView: View {
    @EnvironmentObject var viewModel: ReservationViewModel
    
    let room: Room
    
    @State private var scale = 1.0
    
    // MARK: - Body
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    ZStack {
                        ForEach(room.tables) { table in
                            Button {
                                
                            } label: {
                                TableView(table: table)
                                    .offset(table.offset)
                                    .scaleEffect(scale)
                            }
                        }
                    }
                    .frame(width: room.size.width * scale, height: room.size.height * scale)
                    .border(Color.accentColor)
                }
                .magnificationGesture(scale: $scale, maximumScale: 5, minimumScale: 0.2)
                .task {
                    scale = room.perfectScale(inGeometry: geometry)
                }
            }
            
            DatePicker("Datum und Zeit", selection: .constant(Date.now), displayedComponents: [.date, .hourAndMinute])
                .padding()
                .background(.regularMaterial)
            
        }
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Previews
struct RoomView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoomView(room: .examples[0])
        }
    }
}
