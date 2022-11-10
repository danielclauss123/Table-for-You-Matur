import MapKit

extension MKLocalSearchCompletion {
    /// The coordinate of the place represented by the completion.
    func coordinate() async throws -> CLLocationCoordinate2D {
        let localSearchRequest = MKLocalSearch.Request(completion: self)
        let localSearch = MKLocalSearch(request: localSearchRequest)
        
        let response = try await localSearch.start()
        
        guard let placemark = response.mapItems.first?.placemark else {
            throw MKError(.placemarkNotFound)
        }
        
        return placemark.coordinate
    }
    
    /// The title and subtitle of the completion in a nice format.
    var fullText: String {
        "\(title)\(subtitle.isEmpty ? "" : ", \(subtitle)")"
    }
}
