//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class Filters: NSObject {
  let categories: [String]?
  let deals: Bool?
  let distance: Float?
  let sort: YelpSortMode?

  init(sort: YelpSortMode?, categories: [String]?, deals: Bool?, distance: Float?) {
    self.sort = sort
    self.categories = categories
    self.deals = deals
    self.distance = distance
  }
}
