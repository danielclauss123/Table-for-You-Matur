import SwiftUI
import MapKit

struct RestaurantsMapView: UIViewRepresentable {
    @Binding var selectedRestaurant: YelpRestaurantDetail?
    @Binding var centerCoordinate: CLLocationCoordinate2D
    
    let restaurants: [YelpRestaurantDetail]
    
    let settableMapCenter: CLLocationCoordinate2D?
    
    private let locationFetcher = LocationFetcher()
    
    @State private var lastSetMapCenter: CLLocationCoordinate2D?
    @State private var lastCenterCoordinate = CLLocationCoordinate2D()
    
    // MARK: Make UIView
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.delegate = context.coordinator
        mapView.showsCompass = false
        mapView.showsUserLocation = true
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        locationFetcher.start()
        
        return mapView
    }
    
    // MARK: Update UIView
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Add and Remove Annotations
        /*
         Only the restaurant annotations count because there are also the UserAnnotations or cluster annotations.
         */
        let uiViewAnnotations = uiView.annotations.filter {
            $0 is RestaurantAnnotation
        } as? [RestaurantAnnotation] ?? []
        
        let annotationsToRemove = uiViewAnnotations.filter {
            !restaurants.contains($0.restaurant)
        }
        
        let annotationsToAdd = restaurants.filter {
            !uiViewAnnotations.map { $0.restaurant }.contains($0)
        }.map {
            RestaurantAnnotation(restaurant: $0)
        }
        
        uiView.removeAnnotations(annotationsToRemove)
        uiView.addAnnotations(annotationsToAdd)
        
        // Check Selected Restaurant
        if selectedRestaurant == nil {
            let selectedRestaurantAnnotations = uiView.selectedAnnotations.filter {
                $0 is RestaurantAnnotation
            }
            
            selectedRestaurantAnnotations.forEach {
                uiView.deselectAnnotation($0, animated: true)
            }
        }
        
        /*if settableMapCenter != lastSetMapCenter {
            if let settableMapCenter = settableMapCenter {
                uiView.setRegion(
                    .init(center: settableMapCenter, span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)),
                    animated: true
                )
            }
            
            lastSetMapCenter = settableMapCenter
        }*/
        
        // Set Center
        /* Updates to centerCoordinate from outside trigger the first block, from inside (drag of map) are always made together with update to lastCenterCoordinate. */
        if centerCoordinate != lastCenterCoordinate {
            uiView.setRegion(
                .init(center: centerCoordinate, span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)),
                animated: true
            )
        } /*else {
            centerCoordinate = uiView.centerCoordinate
        }
        
        lastCenterCoordinate = centerCoordinate*/
    }
}

// MARK: - Coordinator
extension RestaurantsMapView {
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: RestaurantsMapView
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            Task {
                await MainActor.run {
                    parent.centerCoordinate = mapView.centerCoordinate
                    parent.lastCenterCoordinate = mapView.centerCoordinate
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !annotation.isEqual(mapView.userLocation) else {
                return MKUserLocationView(annotation: annotation, reuseIdentifier: "userPlacemark")
            }
            
            guard let annotation = annotation as? RestaurantAnnotation else {
                return nil
            }
            
            let identifier = "restaurantPlacemark"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = RestaurantAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            
            /* If this is not here but instead in the init, the cluster annotations don't work anymore after the annotations got removed and re-added.
                Source: https://developer.apple.com/forums/thread/93399
             */
            annotationView?.clusteringIdentifier = "restaurant"
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? RestaurantAnnotation {
                parent.selectedRestaurant = annotation.restaurant
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            if (view.annotation as? RestaurantAnnotation)?.restaurant == parent.selectedRestaurant {
                parent.selectedRestaurant = nil
            }
        }
        
        init(_ parent: RestaurantsMapView) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}


// MARK: - Previews
struct RestaurantsMapView_Previews: PreviewProvider {
    static var previews: some View {
        Container()
    }
    
    struct Container: View {
        @State private var selected: YelpRestaurantDetail?
        @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 47, longitude: 8)
        
        var body: some View {
            VStack {
                RestaurantsMapView(selectedRestaurant: $selected, centerCoordinate: $centerCoordinate, restaurants: YelpRestaurantDetail.examples, settableMapCenter: centerCoordinate)
                
                Button("TAp") {
                    centerCoordinate = .init(latitude: 50, longitude: 2)
                }
                .padding(30)
                
                Text("\(centerCoordinate.latitude)")
            }
        }
    }
}
