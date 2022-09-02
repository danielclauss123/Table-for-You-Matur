import SwiftUI

struct ReservationConfirmationView: View {
    @ObservedObject var viewModel: ReservationViewModel
    
    @Binding var sheetIsPresented: Bool
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: viewModel.yelpRestaurant.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image.defaultPlaceholder()
                        .aspectRatio(1, contentMode: .fit)
                }
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(10)
                
                Text(viewModel.yelpRestaurant.name)
                    .font(.title2.bold())
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(7)
                        .background(.quaternary)
                        .clipShape(Circle())
                }
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.date, style: .time)
                        .font(.headline)
                    +
                    Text(", ")
                        .font(.headline)
                    +
                    Text(viewModel.date, style: .date)
                    
                    Spacer()
                }
                
                Text("\(viewModel.numberOfPeople) \(viewModel.numberOfPeople == 1 ? "Person" : "Personen")")
                    .font(.headline)
                +
                Text(" unter ")
                +
                Text(viewModel.customerName)
            }
            
            Button {
                viewModel.uploadReservation()
                if !viewModel.showingErrorAlert {
                    sheetIsPresented = false
                }
            } label: {
                Text("Reservieren")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(.quaternary)
        }
        .padding()
        .alert(viewModel.errorMessage ?? "Unbekanntes Problem", isPresented: $viewModel.showingErrorAlert) {
            Button("Ok") { }
        }
    }
}


// MARK: - Previews
struct ReservationConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReservationConfirmationView(viewModel: .example, sheetIsPresented: .constant(true))
        }
    }
}
