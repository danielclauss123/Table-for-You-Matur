import SwiftUI

struct ReservationRowView: View {
    let reservation: Reservation
    let restaurant: YelpRestaurantDetail?
    
    // MARK: Body
    var body: some View {
        NavigationLink {
            Text("Detail View")
        } label: {
            HStack {
                AsyncImage(url: URL(string: restaurant?.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image.defaultPlaceholder()
                        .aspectRatio(1, contentMode: .fit)
                }
                .frame(width: 70, height: 70)
                .clipped()
                .cornerRadius(10)
                
                VStack(alignment: .leading) {
                    Text(restaurant?.name ?? "")
                        .font(.title3.bold())
                    
                    HStack(spacing: 0) {
                        Text(reservation.date, style: .time)
                        +
                        Text(", ")
                        
                        Text(reservation.date, style: .date)
                            .lineLimit(1)
                    }
                    
                    Text("\(reservation.numberOfPeople) \(reservation.numberOfPeople == 1 ? "Person" : "Personen")")
                }
            }
        }

    }
}


// MARK: - Previews
struct ReservationRowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                ReservationRowView(reservation: .example, restaurant: .fullExample1)
                ReservationRowView(reservation: .example, restaurant: nil)
            }
        }
    }
}
