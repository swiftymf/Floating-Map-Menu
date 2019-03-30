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

class ViewController: UIViewController, MKMapViewDelegate, FloatingPanelControllerDelegate {

    var fpc: FloatingPanelController!
    var trashVC: TrashTableViewController!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fpc = FloatingPanelController()
        fpc.delegate = self
        
        trashVC = storyboard?.instantiateViewController(withIdentifier: "TrashPanel") as? TrashTableViewController
        
        fpc.set(contentViewController: trashVC)
        fpc.track(scrollView: trashVC.tableView)
        fpc.addPanel(toParent: self)
        
        view.addSubview(fpc.view)
        

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fpc.removePanelFromParent(animated: true)
    }
    


    
}


