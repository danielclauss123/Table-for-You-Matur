import SwiftUI

struct NewReservationView: View {
    @StateObject var viewModel: ReservationViewModel
    
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
                
                Section {
                    NavigationLink("Tisch auswählen", destination: RoomListView(restaurant: viewModel.restaurant, viewModel: viewModel))
                        .font(.body.bold())
                        .foregroundColor(.accentColor)
                        .disabled(!viewModel.detailsAreValid)
                }
            }
            .navigationTitle("Reservierung")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Init
    init(restaurant: Restaurant) {
        self._viewModel = StateObject(wrappedValue: ReservationViewModel(restaurant: restaurant))
    }
}


// MARK: - Previews
struct NewReservationView_Previews: PreviewProvider {
    static var previews: some View {
        NewReservationView(restaurant: Restaurant.examples[0])
    }
}
