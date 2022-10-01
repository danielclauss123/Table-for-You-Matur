import SwiftUI
import MapKit

struct LocationSearchButton: View {
    @ObservedObject var locationSearcher: LocationSearcher
    
    var mapCenter: CLLocationCoordinate2D?
    var tapAction: () -> Void = { }
    
    @State private var showingSearchSheet = false
    
    var symbolVariant: SymbolVariants {
        guard locationSearcher.coordinate != nil else {
            return .slash
        }
        
        switch locationSearcher.locationSource {
        case .device:
            return .fill
        case .search, .map:
            return .none
        case .undefined:
            return .slash
        }
    }
    
    var foregroundColor: Color {
        guard locationSearcher.coordinate != nil else {
            return .secondary
        }
        
        switch locationSearcher.locationSource {
        case .device, .map:
            return .accentColor
        case .search:
            return .primary
        case .undefined:
            return .secondary
        }
    }
    
    // MARK: - Body
    var body: some View {
        Button {
            showingSearchSheet = true
            tapAction()
        } label: {
            Label(
                locationSearcher.coordinate != nil ? locationSearcher.searchText : "Unbekannt",
                systemImage: locationSearcher.locationSource == .map ? "map" : "location"
            )
            .symbolVariant(symbolVariant)
            .font(.subheadline.bold())
            .foregroundColor(foregroundColor)
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
        LocationSearchButton(locationSearcher: .example)
            .previewLayout(.sizeThatFits)
    }
}
