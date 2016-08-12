//
//  OptionCell.swift
//  Yelp
//
//  Created by Gil Birman on 8/9/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class OptionCell: UITableViewCell {

  let onColor = UIColor.redColor()
  let offColor = UIColor.clearColor()

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
    optionCircleView.backgroundColor = selected ? UIColor.redColor() : normalBackgroundColor()
  }

  override func setHighlighted(highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    optionCircleView.backgroundColor = highlighted ? UIColor.blackColor() : normalBackgroundColor()
  }

  // MARK: Private

  private func normalBackgroundColor() -> UIColor {
    if let on = on where on {
      return onColor
    } else {
      return offColor
    }
  }

}
