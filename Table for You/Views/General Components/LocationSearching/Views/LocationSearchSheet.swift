import SwiftUI
import MapKit

struct LocationSearchSheet: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var locationSearcher: LocationSearcher
    
    var mapCenter: CLLocationCoordinate2D?
    
    @FocusState private var searchFieldIsFocused: Bool
    
    // MARK: Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    SearchField(
                        "Adresse, Postleitzahl, Stadt, Kanton...",
                        text: $locationSearcher.searchText,
                        systemImage: "location.magnifyingglass",
                        backgroundColor: Color(uiColor: .systemGray5)
                    )
                    .textContentType(.fullStreetAddress)
                    .focused($searchFieldIsFocused)
                    .foregroundColor(locationSearcher.locationSource == .device || locationSearcher.locationSource == .map ? .accentColor : .primary)
                    .onSubmit {
                        if let completion = locationSearcher.searchCompletions.first,  locationSearcher.locationSource == .search {
                            Task {
                                await locationSearcher.selectCompletion(completion)
                                dismiss()
                            }
                        } else {
                            locationSearcher.locationSource = .device
                            dismiss()
                        }
                    }
                    .onChange(of: searchFieldIsFocused) { newValue in
                        if newValue {
                            locationSearcher.locationSource = .search
                        }
                    }
                    
                    if let errorMessage = locationSearcher.errorMessage {
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                List {
                    userLocationButton
                    if let mapCenter = mapCenter {
                        mapCenterButton(mapCenter)
                    }
                    
                    if locationSearcher.locationSource == .search {
                        ForEach(locationSearcher.searchCompletions, id: \.self) { completion in
                            searchCompletionButton(completion)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Standort")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(uiColor: colorScheme == .light ? .secondarySystemBackground : .systemBackground))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        if locationSearcher.locationSource == .search {
                            if let completion = locationSearcher.searchCompletions.first {
                                Task {
                                    await locationSearcher.selectCompletion(completion)
                                    dismiss()
                                }
                            } else {
                                locationSearcher.locationSource = .device
                                dismiss()
                            }
                        } else {
                            dismiss()
                        }
                    }
                }
            }
        }
        .interactiveDismissDisabled()
    }
    
    // MARK: User Location Button
    var userLocationButton: some View {
        Button {
            locationSearcher.locationSource = .device
            searchFieldIsFocused = false
            dismiss()
        } label: {
            HStack {
                Image(systemName: "location")
                    .symbolVariant(locationSearcher.locationServiceAvailable ? .fill : .slash)
                    .font(.title3)
                    .padding(.trailing, 10)
                
                Text("Mein Standort")
                    .bold()
            }
        }
        .disabled(!locationSearcher.locationServiceAvailable)
    }
    
    // MARK: User Location Button
    func mapCenterButton(_ mapCenter: CLLocationCoordinate2D) -> some View {
        Button {
            locationSearcher.selectMapCoordinate(mapCenter)
            searchFieldIsFocused = false
            dismiss()
        } label: {
            HStack {
                Image(systemName: "map")
                    .font(.title3)
                    .padding(.trailing, 10)
                
                Text("Kartenbereich")
                    .bold()
            }
        }
    }
    
    // MARK: Search Completion Button
    func searchCompletionButton(_ completion: MKLocalSearchCompletion) -> some View {
        Button {
            Task {
                await locationSearcher.selectCompletion(completion)
                dismiss()
            }
        } label: {
            HStack {
                Image(systemName: "location")
                    .font(.title3)
                    .padding(.trailing, 10)
                
                VStack(alignment: .leading) {
                    Text(completion.title)
                        .bold()
                    if !completion.subtitle.isEmpty {
                        Text(completion.subtitle)
                    }
                }
            }
        }
        .foregroundColor(.primary)
    }
}


// MARK: - Previews
struct LocationSearchSheet_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchSheet(locationSearcher: .init())
    }
}
