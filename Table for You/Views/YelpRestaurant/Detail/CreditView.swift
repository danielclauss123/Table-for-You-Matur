import SwiftUI

extension RestaurantDetailSheet {
    struct CreditView: View {
        let yelpURL: URL
        
        var text: String {
            "Die Restaurant Informationen wurden von Yelp zur verfügung gestellt. **[Mehr auf Yelp](\(yelpURL.absoluteString))**"
        }
        
        // MARK: - Body
        var body: some View {
            Text(.init(text))
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
    }
}

// MARK: - Previews
struct CreditView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantDetailSheet.CreditView(yelpURL: YelpRestaurantDetail.fullExample1.yelpURL)
            .previewLayout(.sizeThatFits)
    }
}
