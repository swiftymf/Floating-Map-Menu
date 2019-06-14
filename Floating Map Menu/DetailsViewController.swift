//
//  DetailsViewController.swift
//  Floating Map Menu
//
//  Created by Markith on 4/11/19.
//  Copyright © 2019 SwiftyMF. All rights reserved.
//

import UIKit
import MapKit
import FloatingPanel

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var phoneLabel: UILabel?
    
    var nameText = ""
    var addressText = ""
    var phoneText = ""
    
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel?.text = nameText
        addressLabel?.text = addressText
        phoneLabel?.text = phoneText
    }
    
    @IBAction func dimissDetailView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)

    }
    
}
