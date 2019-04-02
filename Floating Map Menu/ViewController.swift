//
//  ViewController.swift
//  Floating Map Menu
//
//  Created by Markith on 3/29/19.
//  Copyright © 2019 SwiftyMF. All rights reserved.
//

import UIKit
import FloatingPanel
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, FloatingPanelControllerDelegate, UISearchBarDelegate {

    var fpc: FloatingPanelController!
    var trashVC: TrashTableViewController!
//    var places: [MKMapItem]?
    var mapItems: [MKMapItem]?  {
        didSet {
            displayAnnotations()
        }
    }
    var searchBarText = ""

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet private var locationManager: LocationManager!
    @IBOutlet weak var mapView: MKMapView!
    private var locationManagerObserver: NSKeyValueObservation?
    private var mapChangedFromUserInteraction = false

    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            mapItems = nil
            localSearch?.cancel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchButton.isHidden = true
        self.mapView.delegate = self
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        trashVC = storyboard?.instantiateViewController(withIdentifier: "TrashPanel") as? TrashTableViewController
        
        fpc.set(contentViewController: trashVC)
        fpc.track(scrollView: trashVC.tableView)
        fpc.addPanel(toParent: self)
                
        view.addSubview(fpc.view)
        
        mapView.userTrackingMode = .follow
        
        // might need this for something?
//        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: AnnotationReuseID.pin.rawValue)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        trashVC.searchBar?.delegate = self

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fpc.removePanelFromParent(animated: true)
    }
    
    // MARK: UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        mapMovedSearch(for: trashVC.searchBar?.text)
        fpc.move(to: .half, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton  = false
        trashVC.hideHeader()
        fpc.move(to: .half, animated: true)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        trashVC.showHeader()
        trashVC.tableView.alpha = 1.0
        fpc.move(to: .full, animated: true)
    }

    
    // MARK: FloatingPanelControllerDelegate
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        switch newCollection.verticalSizeClass {
        case .compact:
            fpc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
            fpc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
            return SearchPanelLandscapeLayout()
        default:
            fpc.surfaceView.borderWidth = 0.0
            fpc.surfaceView.borderColor = nil
            return nil
        }
    }
    
    func floatingPanelDidMove(_ vc: FloatingPanelController) {
        let y = vc.surfaceView.frame.origin.y
        let tipY = vc.originYOfSurface(for: .tip)
        if y > tipY - 44.0 {
            let progress = max(0.0, min((tipY  - y) / 44.0, 1.0))
            self.trashVC.tableView.alpha = progress
        }
    }
    
    func floatingPanelWillBeginDragging(_ vc: FloatingPanelController) {
        if vc.position == .full {
            trashVC.searchBar?.showsCancelButton = false
            trashVC.searchBar?.resignFirstResponder()
        }
    }
    
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        if targetPosition != .full {
            trashVC.hideHeader()
        }
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: .allowUserInteraction,
                       animations: {
                        if targetPosition == .tip {
                            self.trashVC.tableView.alpha = 0.0
                        } else {
                            self.trashVC.tableView.alpha = 1.0
                        }
        }, completion: nil)
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        mapView.removeAnnotations(mapView.annotations)
        mapMovedSearch(for: trashVC.searchBar?.text)
    }
    
    // MapView Delegate - Unhide search button and update search results when user moves map
    
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        if (mapChangedFromUserInteraction) {
            // user changed map region
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (mapChangedFromUserInteraction) {
            searchButton.isHidden = false
        }
    }
    
    func mapMovedSearch(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        let region = MKCoordinateRegion(center: mapView.centerCoordinate, latitudinalMeters: 12_000, longitudinalMeters: 12_000)
        searchRequest.naturalLanguageQuery = queryString
        searchRequest.region = region

        // TODO: - combine these function into one, no need to call them both and have them display the same things
        self.search(using: searchRequest)
        trashVC.search(using: searchRequest)
    }

    func search(using searchRequest: MKLocalSearch.Request) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [weak self] (response, error) in
            guard error == nil else {
                //self?.displaySearchError(error)
                return
            }
            self?.mapItems = response?.mapItems // mapItems DO change when the map view moves
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func displayAnnotations() {

        mapView.removeAnnotations(mapView.annotations)

        guard let mapItems = mapItems else { return }

        if mapItems.count == 1, let item = mapItems.first {
            title = item.name
        } else {
            title = NSLocalizedString("TITLE_ALL_PLACES", comment: "All Places view controller title")
        }
        // Turn the array of MKMapItem objects into an annotation with a title and URL that can be shown on the map.
        let annotations = mapItems.compactMap { (mapItem) -> PlaceAnnotation? in
            guard let coordinate = mapItem.placemark.location?.coordinate else { return nil }
            
            let annotation = PlaceAnnotation(coordinate: coordinate)
            annotation.title = mapItem.name
            annotation.url = mapItem.url
            
            
            return annotation
        }
        
        mapView.addAnnotations(annotations)
    }
}

public class SearchPanelLandscapeLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .tip]
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0
        case .tip: return 69.0
        default: return nil
        }
    }
    
    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        if #available(iOS 11.0, *) {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8.0),
                surfaceView.widthAnchor.constraint(equalToConstant: 291),
            ]
        } else {
            return [
                surfaceView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0),
                surfaceView.widthAnchor.constraint(equalToConstant: 291),
            ]
        }
    }
    
    public func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        return 0.0
    }
}
