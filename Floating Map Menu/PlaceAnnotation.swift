/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Custom pin annotation for display found places.
*/

import MapKit


// Why does this have to be a class and not a struct?
// Classes can inherit, so maybe this one needs to inherit from NSObject and MKAnnotation? but why?
// Are there properties that the superclass needs to intialize? YES, SEE BELOW
class PlaceAnnotation: NSObject, MKAnnotation {
    
    // This property is required for MKAnnotation
    // However, below, it includes the @objc dynamic, why is that required and what is KVO compliant?
    //var coordinate: CLLocationCoordinate2D
    
    /*
    This property is declared with `@objc dynamic` to meet the API requirement that the coordinate property on all MKAnnotations
    must be KVO compliant.
     */
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var url: URL?
    var isOpen: Bool?
    var reviews: [String]?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
}



