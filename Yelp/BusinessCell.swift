//
//  BusinessCell.swift
//  Yelp
//
//  Created by Gil Birman on 8/8/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

  @IBOutlet weak var starImageView: UIImageView!
  @IBOutlet weak var thumbImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var reviewCountLabel: UILabel!

  var business: Business! {
    didSet {
      addressLabel.text = business.address
      categoryLabel.text = business.categories
      distanceLabel.text = business.distance
      titleLabel.text = business.name

      thumbImageView.setImageWithURL(business.imageURL!)
      starImageView.setImageWithURL(business.ratingImageURL!)

    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    thumbImageView.layer.cornerRadius = 3
    thumbImageView.clipsToBounds = true
  }
}
