import MapKit

class RestaurantAnnotation: MKPointAnnotation {
    let restaurant: YelpRestaurantDetail
    
    init(restaurant: YelpRestaurantDetail) {
        self.restaurant = restaurant
        
        super.init()
        
        coordinate = restaurant.coordinate
        title = restaurant.name
    }
}
