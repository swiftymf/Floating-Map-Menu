//
//  TrashTableViewController.swift
//  Floating Map Menu
//
//  Created by Markith on 3/29/19.
//  Copyright © 2019 SwiftyMF. All rights reserved.
//

import CoreLocation
import FloatingPanel
import MapKit
import UIKit

// Change the name of this if I don't start over with a new project
class TrashTableViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var places: [MKMapItem]? {
        didSet {
            tableView.reloadData()
        }
    }
    
    private enum SegueID: String {
        case showDetail
        case showAll
    }
    
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
        }
    }
    
    private enum CellReuseID: String {
        case resultCell
    }
    
    private var searchController: UISearchController!
    private var boundingRegion: MKCoordinateRegion?
    private var suggestionController: SuggestionsTableTableViewController!
    @IBOutlet private var locationManager: LocationManager!
    private var locationManagerObserver: NSKeyValueObservation?
    private var foregroundRestorationObserver: NSObjectProtocol?
    var searchBarText = ""
    var mapItems: [MKMapItem]?
    var arrayOfPlaces = [tableViewItem]()
    var mainVC = ViewController()
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainVC = (storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? ViewController)!
        
        locationManager.requestLocation()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar?.placeholder = "Search for a place or address"
        definesPresentationContext = true
        places = mainVC.mapItems
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 10, *) {
            visualEffectView.layer.cornerRadius = 9.0
            visualEffectView.clipsToBounds = true
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        suggestionController = SuggestionsTableTableViewController()
        suggestionController.tableView.delegate = self
        
        searchController = UISearchController(searchResultsController: suggestionController)
        searchController.searchResultsUpdater = suggestionController
        
        searchController.searchBar.isUserInteractionEnabled = false
        searchController.searchBar.alpha = 0.5
        
        locationManagerObserver = locationManager.observe(\LocationManager.currentLocation) { [weak self] (_, _) in
            if let location = self?.locationManager.currentLocation {
                // This sample only searches for nearby locations, defined by the device's location. Once the current location is
                // determined, enable the search functionality.
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 12_000, longitudinalMeters: 12_000)
                
                self?.suggestionController.searchCompleter.region = region
                self?.boundingRegion = region
                
                self?.searchController.searchBar.isUserInteractionEnabled = true
                self?.searchController.searchBar.alpha = 1.0
                self?.tableView.reloadData()
            }
        }
        
        let name = UIApplication.willEnterForegroundNotification
        foregroundRestorationObserver = NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: { [weak self] (_) in
            // Get a new location when returning from Settings to enable location services.
            self?.locationManager.requestLocation()
        })
    }
    
    func showHeader() {
        changeHeader(height: 116.0)
    }
    
    func hideHeader() {
        changeHeader(height: 0.0)
    }
    
    func changeHeader(height: CGFloat) {
        tableView.beginUpdates()
        if let headerView = tableView.tableHeaderView  {
            UIView.animate(withDuration: 0.25) {
                var frame = headerView.frame
                frame.size.height = height
                self.tableView.tableHeaderView?.frame = frame
            }
        }
        tableView.endUpdates()
    }
    
    /// - Parameter suggestedCompletion: A search completion provided by `MKLocalSearchCompleter` when tapping on a search completion table row
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        print("search(for suggestionCompletion")
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
        
    }
    
    /// - Parameter queryString: A search string from the text the user entered into `UISearchBar`
    private func search(for queryString: String?) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = queryString
        search(using: searchRequest)
    }
    
    /// - Tag: SearchRequest
    func search(using searchRequest: MKLocalSearch.Request) {
        // Use the network activity indicator as a hint to the user that a search is in progress.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [weak self] (response, error) in
            guard error == nil else {
                self?.displaySearchError(error)
                return
            }
            self?.arrayOfPlaces = []
            self?.places = response?.mapItems
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    
    private func displaySearchError(_ error: Error?) {
        if let error = error as NSError?, let errorString = error.userInfo[NSLocalizedDescriptionKey] as? String {
            let alertController = UIAlertController(title: "Could not find any places.", message: errorString, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard locationManager.currentLocation != nil else { return 1 }
//        return arrayOfPlaces.count
//    }
}

struct tableViewItem {
    var name: String
    var address: String
    
    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
}

extension TrashTableViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard locationManager.currentLocation != nil else { return 1 }
        return places?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard locationManager.currentLocation != nil else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = NSLocalizedString("LOCATION_SERVICES_WAITING", comment: "Waiting for location table cell")
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            cell.accessoryView = spinner
            
            return cell
        }
        
        //let arrayAnnotations = [mainVC.bicycleCoffee, mainVC.tiltCoffeeBar, mainVC.kohiiCoffeeCo, mainVC.cafeDulce, mainVC.bae, mainVC.donatsu, mainVC.giorgiPorgi]
        
        if places != nil {
            for place in places ?? [] {
                let item = tableViewItem(name: place.name!, address: place.placemark.postalAddress!.street)
                arrayOfPlaces.append(item)
            }
            //        } else {
            //            for place in arrayAnnotations {
            //                let item = tableViewItem(name: place.title!, address: "\(place.coordinate)")
            //                print("item: \(item)")
            //                arrayOfPlaces.append(item)
            //            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! SearchCell
        
        if !arrayOfPlaces.isEmpty {
            let place = arrayOfPlaces[indexPath.row]
            cell.titleLabel?.text = place.name
            cell.subTitleLabel?.text =  place.address
        } else {
            cell.titleLabel?.text = ""
            cell.subTitleLabel?.text =  ""
        }
        
        return cell
        
    }
    
}

extension TrashTableViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let fpc = FloatingPanelController()
        var detailsVC = DetailsViewController()
        detailsVC = (storyboard?.instantiateViewController(withIdentifier: "DetailsPanel") as? DetailsViewController)!
        
        // Crashes, most likely due to empty array or out of index.
        // Track the array and see where the data is coming from 
        detailsVC.nameText = (places?[indexPath.row].name)!
        detailsVC.phoneText = (places?[indexPath.row].phoneNumber)!
        detailsVC.addressText = places?[indexPath.row].placemark.postalAddress?.street ?? "unknown address"
        fpc.set(contentViewController: detailsVC)
        
        fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
        self.present(fpc, animated: true, completion: nil)

        // Can't dismiss until I figure out how to bring it back
        //        dismiss(animated: true, completion: nil)
        
        //        guard locationManager.currentLocation != nil else { return }
        //
        //        if tableView == suggestionController.tableView, let suggestion = suggestionController.completerResults?[indexPath.row] {
        //            searchController.isActive = false
        //            searchController.searchBar.text = suggestion.title
        //            search(for: suggestion)
        //        }
    }
}

extension TrashTableViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        search(for: searchBar.text)
    }
}

// MARK: - Get Placemark
extension LocationManager {
    
    func getPlace(for location: CLLocation,
                  completion: @escaping (CLPlacemark?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            completion(placemark)
        }
    }
}

// TODO: - Implement Firebase:
        //  Hardcode some entries to start off with and make sure they show in the app
        //  Have them integrate with MapKit search results
        //  Make sure Firebase results override MapKit results

// TODO: - hide searchVC when DetailsVC is shown. Show searchVC when detailsVC is dismissed

// TODO: - Can I convert all MKMaptItems to PlaceAnnotations when search results come in?
// Should be doable since I only get 10 results at a time

// TODO: - add suggestion completion functions
// code is in this project, but it's not currently working at all
// This needs to show up like another Floating Menu
// This might not be working the same way that tableView info isn't showing up at times it should be

// TODO: - custom annotation model ********************
// Annotation view: when tapped shows business name, isOpen, overall rating
// When annotation info disclosure is tapped, have floating panel pop up with all the location's details

// TODO: - Show details in separate floating panel when cell is tapped

// TODO: - Currently using search functions in both viewcontroller files, change to just being in one

// TODO: - tableView - turn coordinates into an address or just get the address from the search results

// TODO: - Cleanup: rename trashVC, rename refreshButton, find other things to rename
// refactor code so functions and names make more sense, no copy/pasta code!

// TODO: - sort tableView results by distance from userLocation or ***center of current mapView***

// TODO: - Is it reasonable to auto-add MapKit locations myDB every time a user does a search?
// Would need to figure out a way to track changes
// The only way MapKit might tell me this is if the location simply doesn't show up, in which case I could probably depend on users to make on comment on that location that it's closed.
// Load myDB in background based on current mapLocation, if location moves, load it prior to running search
// When MapKit returns results, check to see if they are in myDB, if not, add it
// For tableView and annotations, use myDB data, which should include MapKit locations if working properly

// Because of Apple's limited junk with MapKit, I will use the results mainly to find a location the first time. After that, I will use my own database to populate those locations. So my database will need to store all of the important information.
// Displaying my mapItems and Apple mapItems: can I run cellForRow twice? or have it use data from two different arrays?
// for the tableview, I don't think I want separate sections, just indicator, like color, to show reviewed vs non-reviewed places
// Annotations: if a location has no data in my database, the annotation will show name and option to add info?
// if it does have data in my database, it will show relevant info (name, open/closed or hours, etc.)

// I might need to moderate any user reviews, etc. For example, if a businesses closes, either remove from myDB or change color of annotation, or put prominent notification in location details so users don't waste time going there.




// MEETUP QUESTIONS:
// PRIORITY - STRUCT/CLASS OF MAPITEMS/PLACES
// How should I change PlaceAnnotation Class?
// make it a struct instead?
// Will that work with the CLLocationCoordinate2D?
// What does all of this mean:     @objc dynamic var coordinate: CLLocationCoordinate2D
// Do I need two different structs for tableView and annotations or can I just use one?
// This way there only one array to keep track of that has all properties


// Get rid of for loops using functional Swift
// Ask what am I trying to do with the for loop and find the function that does it for me.
// .map, .sorted, .reduce, .foreach, etc.
