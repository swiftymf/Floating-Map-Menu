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

class ViewController: UIViewController, MKMapViewDelegate, FloatingPanelControllerDelegate {

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
    


    
}


