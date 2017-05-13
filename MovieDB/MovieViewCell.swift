//
//  MovieViewCell.swift
//  MovieDB
//
//  Created by Duy Bùi on 5/12/17.
//  Copyright © 2017 Duy Bùi. All rights reserved.
//

import UIKit

class MovieViewCell: UITableViewCell {

    
    @IBOutlet weak var imgPoster: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblOverview: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
