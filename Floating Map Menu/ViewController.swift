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
    
    @IBOutlet private var locationManager: LocationManager!
    @IBOutlet weak var mapView: MKMapView!
    private var locationManagerObserver: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        trashVC = storyboard?.instantiateViewController(withIdentifier: "TrashPanel") as? TrashTableViewController
        
        fpc.set(contentViewController: trashVC)
        fpc.track(scrollView: trashVC.tableView)
        fpc.addPanel(toParent: self)
        
        trashVC.searchBar?.delegate = self
        
        view.addSubview(fpc.view)
        
        mapView.userTrackingMode = .follow
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.requestLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fpc.removePanelFromParent(animated: true)
    }
    
    // MARK: UISearchBarDelegate
    
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

}


