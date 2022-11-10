import SwiftUI

struct RestaurantRowView: View {
    let restaurant: YelpRestaurantDetail
    let onTap: () -> Void
    
    @ScaledMetric var imageWidth = 70.0
    
    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            VStack {
                HStack {
                    AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                    } placeholder: {
                        Image.defaultPlaceholder()
                            .font(.headline)
                            .aspectRatio(1, contentMode: .fit)
                    }
                    .frame(width: imageWidth, height: imageWidth)
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading) {
                        Text(restaurant.name)
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        openingHours
                        
                        reviews
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                Divider()
            }
        }
    }
    
    // MARK: - Opening Hours
    var openingHours: some View {
        Group {
            if let openingHours = restaurant.openingHours {
                HStack {
                    Text(openingHours.isOpenNow ? "Geöffnet" : "Geschlossen")
                        .foregroundColor(openingHours.isOpenNow ? .green : .red)
                        .bold()
                    
                    if openingHours.isOpenNow {
                        DayHoursView(dayHours: openingHours.todaysHours)
                    }
                }
            }
        }
    }
    
    // MARK: - Price and Reviews
    var reviews: some View {
        HStack {
            if let rating = restaurant.rating, let reviewCount = restaurant.reviewCount {
                ShortRatingView(rating: rating, reviewCount: reviewCount)
            }
            if let priceInt = restaurant.priceInt {
                ShortPriceView(price: priceInt)
            }
        }
    }
}


// MARK: - Previews
struct RestaurantRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RestaurantRowView(restaurant: .fullExample1) { }
            
            RestaurantRowView(restaurant: .lackingExample) { }
        }
        .previewLayout(.sizeThatFits)
    }
}
