import SwiftUI

struct NewReservationView: View {
    @StateObject var viewModel: ReservationViewModel
    @StateObject var roomRepository: RoomRepository
    @StateObject var reservationRepository: ReservationRepository // TODO: Connection to viewModel
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                Section("Reservierung für") {
                    TextField("Dein Name", text: $viewModel.customerName)
                }
                
                Section("Anzahl Personen") {
                    Stepper("\(viewModel.numberOfPeople) Personen", value: $viewModel.numberOfPeople, in: 1 ... 20)
                }
                
                Section("Datum und Zeit") {
                    DatePicker("Datum und Zeit Auswahl", selection: $viewModel.date, in: Date.now...)
                        .datePickerStyle(.graphical)
                }
                
                rooms
            }
            .navigationTitle("Reservierung")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Rooms
    var rooms: some View {
        Section {
            switch roomRepository.loadingStatus {
                case .loading:
                    EmptyView()
                case .firestoreError(let error):
                    Text("Fehler\n")
                        .font(.headline)
                    +
                    Text(error)
                        .foregroundColor(.secondary)
                    Button("Neu laden") {
                        
                    }
                case .ready:
                    ForEach(roomRepository.rooms) { room in
                        RoomRowView(room: room, viewModel: viewModel, reservationRepository: reservationRepository)
                    }
            }
        } header: {
            HStack {
                Text("Wo willst du sitzen?")
                if roomRepository.loadingStatus == .loading {
                    ProgressView()
                        .padding(.leading, 5)
                }
            }
        }
    }
    
    // MARK: - Init
    init(restaurant: Restaurant) {
        self._viewModel = StateObject(wrappedValue: ReservationViewModel(restaurant: restaurant))
        self._roomRepository = StateObject(wrappedValue: RoomRepository(restaurant: restaurant))
        self._reservationRepository = StateObject(wrappedValue: ReservationRepository(restaurant: restaurant, date: Date.now))
    }
    
    // MARK: - Example Init
    fileprivate init() {
        self._viewModel = StateObject(wrappedValue: ReservationViewModel.example)
        self._roomRepository = StateObject(wrappedValue: RoomRepository.example)
        self._reservationRepository = StateObject(wrappedValue: ReservationRepository.example)
    }
}


// MARK: - Previews
struct NewReservationView_Previews: PreviewProvider {
    static var previews: some View {
        NewReservationView()
    }
}
