import SwiftUI

extension YelpRestaurantDetailContentView {
    struct ContactView: View {
        let phone: String
        let displayPhone: String
        
        // MARK: - Body
        var body: some View {
            InsetScrollViewSection(title: "Kontakt") {
                Button {
                    UIApplication.shared.callNumber(phone)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Telefon")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                            
                            Text(displayPhone)
                                .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
}


// MARK: - Previews
struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        YelpRestaurantDetailContentView.ContactView(phone: "0522027422", displayPhone: "0522027422")
            .previewLayout(.sizeThatFits)
    }
}
