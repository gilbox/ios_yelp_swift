//
//  OptionCell.swift
//  Yelp
//
//  Created by Gil Birman on 8/9/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class OptionCell: UITableViewCell {

  @IBOutlet weak var optionCircleView: UIView!
  @IBOutlet weak var titleLabel: UILabel!

  var option: [String:Any]! {
    didSet {
      if let title = option["title"] as? String {
        titleLabel.text = title
      }
    }
  }

  var on: Bool! {
    didSet {
      optionCircleView.backgroundColor = (on ?? false) ? UIColor.redColor() : UIColor.clearColor()
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code

    optionCircleView.layer.cornerRadius = 15
    optionCircleView.layer.borderWidth = 2
    optionCircleView.layer.borderColor = UIColor.redColor().CGColor
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
//    optionCircleView.backgroundColor = UIColor.redColor()
  }

}
