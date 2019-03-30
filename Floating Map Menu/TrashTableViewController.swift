//
//  TrashTableViewController.swift
//  Floating Map Menu
//
//  Created by Markith on 3/29/19.
//  Copyright © 2019 SwiftyMF. All rights reserved.
//

import UIKit

class TrashTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? SearchCell {
            switch indexPath.row {
            case 0:
                //cell.iconImageView.image = UIImage(named: "mark")
                cell.titleLabel.text = "Marked Location"
                cell.subTitleLabel.text = "Golden Gate Bridge, San Francisco"
            case 1:
                //cell.iconImageView.image = UIImage(named: "like")
                cell.titleLabel.text = "Favorites"
                cell.subTitleLabel.text = "0 Places"
            default:
                break
            }
        }
        return cell
    }

}
