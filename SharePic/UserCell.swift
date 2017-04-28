//
//  UserCell.swift
//  SharePic
//
//  Created by Patrick Boyle on 4/21/17.
//  Copyright © 2017 Patrick Boyle. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!;

    @IBOutlet weak var userImage: UIImageView!;
    
    var userID: String!;
}
