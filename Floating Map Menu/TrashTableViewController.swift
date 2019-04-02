//
//  TrashTableViewController.swift
//  Floating Map Menu
//
//  Created by Markith on 3/29/19.
//  Copyright © 2019 SwiftyMF. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

// Change the name of this if I don't start over with a new project
class TrashTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var places: [MKMapItem]? {
        didSet {
            tableView.reloadData()
            //viewAllButton.isEnabled = places != nil
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
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestLocation()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar?.placeholder = "Search for a place or address"
        definesPresentationContext = true

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
        print("awakeFromNib")

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
}

extension TrashTableViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard locationManager.currentLocation != nil else { return 1 }
        return places?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // I think this is returning nil so nothing else with suggestionController is getting called
        // Probably has to do when when the location is gotten
        // probably some observer to check for location?
        // Also update location when the map is moved (then unhide button to "search this area")
        
        guard locationManager.currentLocation != nil else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = NSLocalizedString("LOCATION_SERVICES_WAITING", comment: "Waiting for location table cell")
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            cell.accessoryView = spinner

            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell" /*CellReuseID.resultCell.rawValue*/, for: indexPath) as! SearchCell
        
        if let mapItem = places?[indexPath.row] {
            cell.titleLabel?.text = mapItem.name
            cell.subTitleLabel?.text = "\(String(describing: mapItem.placemark.location?.coordinate))"
        }
        
        return cell
    }
}

extension TrashTableViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
   
        guard locationManager.currentLocation != nil else { return }
        
        if tableView == suggestionController.tableView, let suggestion = suggestionController.completerResults?[indexPath.row] {
            searchController.isActive = false
            searchController.searchBar.text = suggestion.title
            search(for: suggestion)
        }
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

// TODO: - Search Here button
// Search button is added
// need to place at bottom of view and hide until needed
// In Apple Maps app, looks like a navigation bar/button pops up when the regionDidChange is called?

// TODO: - add suggestion completion functions
// code is in this project, but it's not currently working at all
// This needs to show up like another Floating Menu

// TODO: - custom annotation model ********************
// What properties do I want to show in the annotation so people don't have to click into detail
// Or do I just want to show detail in the Floating view

// TODO: - Show details when cell is tapped

// TODO: - Currently using search functions in both viewcontroller files, change to just being in one

// TODO: - tableView - turn coordinates into an address or just get the address from the search results

// TODO: - Cleanup: rename trashVC, rename refreshButton, find other things to rename
// refactor code so functions and names make more sense, no copy/pasta code!
