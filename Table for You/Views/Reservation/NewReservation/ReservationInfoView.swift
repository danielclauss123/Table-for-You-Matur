import SwiftUI

struct ReservationInfoView: View {
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
            }
            .navigationTitle("Reservierung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                NavigationLink("Weiter", destination: RoomListView(restaurant: viewModel.restaurant))
            }
        }
        .environmentObject(viewModel)
    }
    
    // MARK: - Init
    init(restaurant: Restaurant) {
        self._viewModel = StateObject(wrappedValue: ReservationViewModel(restaurant: restaurant))
    }
}

struct ReservationInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationInfoView(restaurant: Restaurant.examples[0])
    }
}
