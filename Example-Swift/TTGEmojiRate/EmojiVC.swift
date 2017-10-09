//
//  EmojiVC.swift
//  TTGEmojiRate_Example
//
//  Created by Christopher G Prince on 10/7/17.
//  Copyright © 2017 Spastic Muffin, LLC. All rights reserved.
//

// A demo of using TTGEmojiRate with a table view.

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class EmojiVC : UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let reuseId = "TableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension EmojiVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
