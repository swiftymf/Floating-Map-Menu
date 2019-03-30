//
//  TrashTableViewController.swift
//  Floating Map Menu
//
//  Created by Markith on 3/29/19.
//  Copyright © 2019 SwiftyMF. All rights reserved.
//

import UIKit

// Change the name of this if I don't start over with a new project
class TrashTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var searchController: UISearchController?
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
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
        
        searchController?.searchBar.isUserInteractionEnabled = false
        searchController?.searchBar.alpha = 0.5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? SearchCell {
            switch indexPath.row {
            case 0:
                //cell.iconImageView.image = UIImage(named: "mark")
                cell.titleLabel.text = "Add search bar above this text"
                cell.subTitleLabel.text = "Should I make buttons for easier searching? "
            case 1:
                //cell.iconImageView.image = UIImage(named: "like")
                cell.titleLabel.text = "Like 'Coffee Shops', 'Bars', 'Libraries', etc."
                cell.subTitleLabel.text = "Decide what custom info should be displayed in these cells"
            default:
                break
            }
        }
        return cell
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
    
    
    // TODO: - add search functions
    // code is in MapSearch project
    
    
    // TODO: - add suggestion completion functions
    // code is in MapSearch project
    // This needs to show up like another Floating Menu
    
    // TODO: - mapItems model
    // var places: [MKMapItem]?

    
    
    
    // TODO: - custom annotation model
    // What properties do I want to show in the annotation so people don't have to click into detail
    // Or do I just want to show detail in the Floating view

    
    
    // TODO: - Search Here button
    // In Apple Maps app, looks like a navigation bar/button pops up when the regionDidChange is called?
}
