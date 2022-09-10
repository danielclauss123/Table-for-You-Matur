import SwiftUI

struct NewReservationView: View {
    @StateObject var viewModel: ReservationVM
    @StateObject var roomRepo: RoomRepo
    @StateObject var reservationRepo: RoomReservationsRepo
    
    @Binding var sheetIsPresented: Bool
    
    var problem: String? {
        if !viewModel.reservationInfosAreValid {
            return "Die eingegebenen Informationen sind nicht genügend oder falsch."
        } else if !viewModel.reservationTimeIsPossible {
            return "Keine Reservation zu dieser Zeit and diesem Tag möglich."
        } else {
            return nil
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                reservationInfos
                
                if let problem = problem {
                    Section("Problem") {
                        Text(problem)
                    }
                }
                
                rooms
            }
            .navigationTitle("Reservierung")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Reservation Infos
    var reservationInfos: some View {
        Group {
            Section("Reservierung für") {
                TextField("Dein Name", text: $viewModel.customerName)
            }
            
            Section("Anzahl Personen") {
                Stepper("\(viewModel.numberOfPeople) Personen", value: $viewModel.numberOfPeople, in: 1 ... 20)
            }
            
            Section("Datum und Zeit") {
                DatePicker("Datum und Zeit Auswahl", selection: $viewModel.date, in: Date.now...)
                    .datePickerStyle(.graphical)
                
                if let openingHours = viewModel.yelpRestaurant.openingHours {
                    DisclosureGroup("Öffnungszeiten") {
                        AllHoursView(openingHours: openingHours)
                            .padding(.bottom, 5)
                        Text("Reservierung sind möglich bis spätestens zwei Stunden vor Schliessung.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Rooms
    var rooms: some View {
        Section {
            switch roomRepo.loadingStatus {
                case .loading:
                    EmptyView()
                case .error(let message):
                VStack {
                    Text(message)
                        .foregroundColor(.secondary)
                    
                    Button {
                        roomRepo.loadRooms()
                    } label: {
                        Label("Nochmal versuchen", systemImage: "arrow.counterclockwise")
                    }
                }
                case .ready:
                    Group {
                        if roomRepo.rooms.isEmpty {
                            Text("Noch kein Raum vorhanden...")
                        } else {
                            ForEach(roomRepo.rooms) { room in
                                RoomRowView(
                                    room: room,
                                    currentReservations: reservationRepo.reservations(forRoomId: room.id),
                                    viewModel: viewModel,
                                    sheetIsPresented: $sheetIsPresented
                                )
                            }
                            .disabled(!viewModel.reservationInfosAreValid || !viewModel.reservationTimeIsPossible)
                        }
                    }
            }
        } header: {
            HStack {
                Text("Wo willst du sitzen?")
                if roomRepo.loadingStatus == .loading {
                    ProgressView()
                        .padding(.leading, 5)
                }
            }
        }
    }
    
    // MARK: - Init
    init(restaurant: Restaurant, yelpRestaurant: YelpRestaurantDetail, sheetIsPresented: Binding<Bool>) {
        let viewModel = ReservationVM(restaurant: restaurant, yelpRestaurant: yelpRestaurant)
        
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._roomRepo = StateObject(wrappedValue: RoomRepo(restaurant: restaurant))
        self._reservationRepo = StateObject(wrappedValue: RoomReservationsRepo(reservationVM: viewModel))
        self._sheetIsPresented = sheetIsPresented
    }
    
    // MARK: - Example Init
    fileprivate init() {
        self._viewModel = StateObject(wrappedValue: ReservationVM.example)
        self._roomRepo = StateObject(wrappedValue: RoomRepo.example)
        self._reservationRepo = StateObject(wrappedValue: RoomReservationsRepo.example)
        self._sheetIsPresented = .constant(true)
    }
}


// MARK: - Previews
struct NewReservationView_Previews: PreviewProvider {
    static var previews: some View {
        NewReservationView()
    }
}
