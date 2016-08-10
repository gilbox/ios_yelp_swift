//
//  HeaderCell.swift
//  Yelp
//
//  Created by Gil Birman on 8/9/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!

  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)

      // Configure the view for the selected state
  }

}
