//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {

  var viewGestureRecognizerForSearchBar: UITapGestureRecognizer!
  var businesses: [Business]!
  let searchBar = UISearchBar()

  @IBOutlet weak var filtersButtonItem: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120

    performSearch("Restaurants")

    self.navigationItem.titleView = searchBar
    searchBar.delegate = self
    searchBar.text = "Restaurants"

    viewGestureRecognizerForSearchBar = UITapGestureRecognizer(target: self, action: #selector(BusinessesViewController.onViewTapped))

    /* Example of Yelp search with more search options specified
     Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
     self.businesses = businesses

     for business in businesses {
     print(business.name!)
     print(business.address!)
     }
     }
     */
  }

  func performSearch(searchTerm: String) {
    Business.searchWithTerm(searchTerm, completion: { (businesses: [Business]!, error: NSError!) -> Void in
      self.businesses = businesses

      for business in businesses {
        print(business.name!)
        print(business.address!)
      }

      self.tableView.reloadData()
    })
  }

  func onViewTapped() {
    if searchBar.isFirstResponder() {
      searchBar.resignFirstResponder()
    }
  }

  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    view.addGestureRecognizer(viewGestureRecognizerForSearchBar)
  }

  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    view.removeGestureRecognizer(viewGestureRecognizerForSearchBar)
  }

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    if let searchTerm = searchBar.text {
      performSearch(searchTerm)
    }
  }

  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    print("-->", searchText)
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return businesses?.count ?? 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell") as! BusinessCell
    cell.business = businesses[indexPath.row]

    return cell
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    let navigationViewController = segue.destinationViewController as! UINavigationController
    let filtersViewController = navigationViewController.topViewController as! FiltersViewController
    filtersViewController.delegate = self
  }

  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
    let categories = filters["categories"] as? [String]
    Business.searchWithTerm("Restaurants", sort: nil, categories: categories, deals: nil) { (businesses: [Business]!, error: NSError!) in
      self.businesses = businesses
      self.tableView.reloadData()
    }
  }
}
