import SwiftUI

struct ReservationConfirmationView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var viewModel: ReservationViewModel
    
    // MARK: - Body
    var body: some View {
        Form {
            VStack(alignment: .leading) {
                Text(viewModel.restaurant.name)
                    .font(.title3.bold())
                
                Text(viewModel.date, style: .time)
                +
                Text(", ")
                +
                Text(viewModel.date, style: .date)
                
                Text("\(viewModel.customerName), \(viewModel.numberOfPeople) \(viewModel.numberOfPeople == 1 ? "Person" : "Personen")")
            }
            
            Section {
                Button {
                    viewModel.uploadReservation()
                    
                    if !viewModel.showingErrorAlert {
                        dismiss()
                    }
                } label: {
                    Text("Reservieren")
                        .font(.body.bold())
                        .foregroundColor(.accentColor)
                }
                .alert(viewModel.errorMessage ?? "Unbekanntes Problem", isPresented: $viewModel.showingErrorAlert) {
                    Button("Ok") { }
                }
            }
        }
        .navigationTitle("Bestätigen")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Previews
struct ReservationConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReservationConfirmationView(viewModel: .init(restaurant: .examples[0]))
        }
    }
}
