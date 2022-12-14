import MapKit

// MARK: - Restaurant Annotation
class RestaurantAnnotationView: MKMarkerAnnotationView {
    init(annotation: RestaurantAnnotation, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        glyphImage = UIImage(systemName: "fork.knife")
        titleVisibility = .visible
        markerTintColor = UIColor(.accentColor)
    }
}


// MARK: - Cluster Annotation
class ClusterAnnotationView: MKMarkerAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        collisionMode = .circle
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        if let cluster = annotation as? MKClusterAnnotation {
            glyphText = "\(cluster.memberAnnotations.count)"
            markerTintColor = UIColor(.accentColor)
        }
    }
}
