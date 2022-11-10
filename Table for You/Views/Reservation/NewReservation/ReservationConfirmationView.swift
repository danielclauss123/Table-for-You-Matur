import SwiftUI

struct ReservationConfirmationView: View {
    @Binding var isShown: Bool
    
    @ObservedObject var viewModel: NewReservationVM
    
    // MARK: Body
    var body: some View {
        VStack {
            header
            
            Divider()
            
            information
            
            reserveButton
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(uiColor: .secondarySystemBackground))
                .shadow(radius: 10)
        }
        .padding()
        .alert(viewModel.errorMessage ?? "Unbekanntes Problem", isPresented: viewModel.errorAlertIsPresented) {
            Button("Ok") { }
        }
    }
    
    // MARK: Header
    var header: some View {
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
                isShown = false
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(7)
                    .background(Color(uiColor: .systemGray4))
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: Information
    var information: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.date, style: .time)
                    .font(.headline)
                +
                Text(", ")
                    .font(.headline)
                +
                Text(viewModel.date, style: .date)
                
                Text("\(viewModel.numberOfPeople) \(viewModel.numberOfPeople == 1 ? "Person" : "Personen")")
                    .font(.headline)
                +
                Text(" unter ")
                +
                Text(viewModel.customerName)
            }
            
            Spacer()
        }
    }
    
    var reserveButton: some View {
        Button {
            viewModel.uploadReservation()
        } label: {
            Text("Reservieren")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}


// MARK: - Previews
struct ReservationConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.accentColor
                .ignoresSafeArea()
            Rectangle().fill(.regularMaterial)
                .ignoresSafeArea()
            
            ReservationConfirmationView(isShown: .constant(true), viewModel: .example)
        }
    }
}
