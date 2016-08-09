//
//  SwitchCell.swift
//  Yelp
//
//  Created by Gil Birman on 8/8/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
  optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {

  @IBOutlet weak var onSwitch: UISwitch!
  @IBOutlet weak var switchLabel: UILabel!

  weak var delegate: SwitchCellDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code

    onSwitch.addTarget(self, action: #selector(SwitchCell.switchValueChanged), forControlEvents: UIControlEvents.ValueChanged)
  }

  func switchValueChanged() {
    delegate?.switchCell?(self, didChangeValue: onSwitch.on)
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
