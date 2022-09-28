import SwiftUI
import MapKit

struct LocationSearchButton: View {
    @StateObject var locationSearcher = LocationSearcher()
    
    @State private var showingSearchSheet = false
    
    var mapCenter: CLLocationCoordinate2D?
    
    var tapAction: () -> Void = { }
    
    // MARK: - Body
    var body: some View {
        Button {
            showingSearchSheet = true
            tapAction()
        } label: {
            Label(
                locationSearcher.coordinate != nil ? locationSearcher.searchText : "Unbekannt",
                systemImage: "location"
            )
            .symbolVariant(locationSearcher.coordinate == nil ? .slash : (locationSearcher.locationSource == .device ? .fill : .none))
            .font(.subheadline.bold())
            .foregroundColor(locationSearcher.coordinate == nil ? .secondary : (locationSearcher.locationSource == .device ? .accentColor : .primary))
        }
        .lineLimit(1)
        .sheet(isPresented: $showingSearchSheet) {
            LocationSearchSheet(locationSearcher: locationSearcher, mapCenter: mapCenter)
        }
    }
}


// MARK: - Previews
struct LocationSearchButton_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchButton(locationSearcher: LocationSearcher())
            .previewLayout(.sizeThatFits)
    }
}
