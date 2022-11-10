import SwiftUI
import MapKit

struct RestaurantsMapView: UIViewRepresentable {
    @Binding var selectedRestaurant: YelpRestaurantDetail?
    @Binding var centerCoordinate: CLLocationCoordinate2D
    
    let restaurants: [YelpRestaurantDetail]
    
    private let locationFetcher = LocationFetcher()
    
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
        if let selectedRestaurant = selectedRestaurant {
            let annotation = uiView.annotations.compactMap {
                $0 as? RestaurantAnnotation
            }.first(where: { $0.restaurant == selectedRestaurant })
            
            if let annotation = annotation {
                uiView.selectAnnotation(annotation, animated: true)
            }
        } else {
            let selectedRestaurantAnnotations = uiView.selectedAnnotations.filter {
                $0 is RestaurantAnnotation
            }
            
            selectedRestaurantAnnotations.forEach {
                uiView.deselectAnnotation($0, animated: true)
            }
        }
        
        // Set Center
        /* Updates to centerCoordinate from outside trigger this because lastCenterCoordinate does not get set from outside. */
        if centerCoordinate != context.coordinator.privateCenterCoordinate {
            uiView.setRegion(
                .init(center: centerCoordinate, span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)),
                animated: true
            )
        }
    }
}

// MARK: - Coordinator
extension RestaurantsMapView {
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RestaurantsMapView
        
        /* This property is needed to check if a change to centerCoordinate came from outside the view. It is in the Coordinator because the view itself is a value type and this leads to problems. */
        var privateCenterCoordinate = CLLocationCoordinate2D()
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            Task {
                await MainActor.run {
                    let center = mapView.centerCoordinate
                    
                    parent.centerCoordinate = center
                    privateCenterCoordinate = center
                }
            }
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
                RestaurantsMapView(selectedRestaurant: $selected, centerCoordinate: $centerCoordinate, restaurants: YelpRestaurantDetail.examples)
                
                Button("Tap") {
                    centerCoordinate = .init(latitude: 50, longitude: 2)
                }
                .padding(30)
                
                Text("\(centerCoordinate.latitude)")
            }
        }
    }
}
