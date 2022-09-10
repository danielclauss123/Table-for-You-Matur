import SwiftUI
import MapKit

struct RestaurantAnnotationsMapView: UIViewRepresentable {
    @Binding var selectedRestaurant: YelpRestaurantDetail?
    
    let restaurants: [YelpRestaurantDetail]
    let center: CLLocationCoordinate2D?
    
    @State private var lastSetCenter: CLLocationCoordinate2D?
    
    private let locationFetcher = LocationFetcher()
    
    var restaurantAnnotations: Set<RestaurantAnnotation> {
        Set(restaurants.map { RestaurantAnnotation(restaurant: $0) })
    }
    
    // MARK: - Make UIView
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.delegate = context.coordinator
        mapView.showsCompass = false
        mapView.showsUserLocation = true
        
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        locationFetcher.start()
        
        return mapView
    }
    
    // MARK: - Update UIView
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // TODO: - There could be a function to deselect the annotation if selected annotation is nil.
        
        /*
         Only the restaurant annotations count because there are also the UserAnnotations or cluster annotations.
         */
        let uiViewRestaurantAnnotations = Set(
            uiView.annotations.filter {
                $0 is RestaurantAnnotation
            } as? [RestaurantAnnotation] ?? []
        )
        
        /*
         The uiView.annotations and the restaurantAnnotations cannot be directly compared, because the restaurantAnnotation property gets recomputed every time it gets called. Instead, the restaurants need to be compared.
         */
        let sameAnnotations = uiViewRestaurantAnnotations.filter {
            restaurants.contains($0.restaurant)
        }
        
        /*
         The same annotations stay, the others get removed and the new ones from restaurantAnnotations get added.
         */
        let sameRestaurants = Array(sameAnnotations).map { $0.restaurant }
        
        let annotationsToRemove = uiViewRestaurantAnnotations.subtracting(sameAnnotations)
        
        let annotationsToAdd = restaurantAnnotations.filter {
            !sameRestaurants.contains($0.restaurant)
        }
        
        uiView.removeAnnotations(Array(annotationsToRemove))
        uiView.addAnnotations(Array(annotationsToAdd))
        
        /*
         The actual center of the map doesn't get compared, because otherwise, dragging the map would be impossible.
         */
        if center != lastSetCenter {
            if let center = center {
                uiView.setRegion(
                    MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
                    , animated: true
                )
            }
            
            // This could lead to problems because updateUIView could be called a second time before the task gets executed.
            Task {
               await MainActor.run {
                    lastSetCenter = center
                }
            }
        }
    }
}

// MARK: - Coordinator
extension RestaurantAnnotationsMapView {
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: RestaurantAnnotationsMapView
        
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
            
            /* If this is not here but instead in the init, the cluster annotations don't work anymore after the annotations got removed and readded.
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
        
        init(_ parent: RestaurantAnnotationsMapView) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}


// MARK: - Previews
struct RestaurantAnnotationsMapView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantAnnotationsMapView(selectedRestaurant: .constant(nil), restaurants: YelpRestaurantDetail.examples, center: CLLocationCoordinate2D(latitude: 47, longitude: 8))
            .ignoresSafeArea()
    }
}
