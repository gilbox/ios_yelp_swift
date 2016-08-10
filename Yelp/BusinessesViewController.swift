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
  var filters: [String:Any]?
  let searchBar = UISearchBar()
  var searchTerm: String?

  @IBOutlet weak var filtersButtonItem: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120


    self.navigationItem.titleView = searchBar
    searchBar.delegate = self
    searchBar.text = searchTerm
    performSearch()

    viewGestureRecognizerForSearchBar = UITapGestureRecognizer(target: self, action: #selector(BusinessesViewController.onViewTapped))
  }

  func performSearch() {
    let searchTerm = self.searchTerm ?? ""
    let categories = filters?["categories"] as? [String]
    let sort = filters?["sort"] as? YelpSortMode
    let deals = filters?["deals"] as? Bool

    Business.searchWithTerm(searchTerm, sort: sort, categories: categories, deals: deals) { (businesses: [Business]!, error: NSError!) in
      self.businesses = businesses
      self.tableView.reloadData()
    }
  }

  func onViewTapped() {
    if searchBar.isFirstResponder() {
      searchBar.resignFirstResponder()
    }
  }

  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    searchBar.text = searchTerm
    view.addGestureRecognizer(viewGestureRecognizerForSearchBar)
  }

  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    view.removeGestureRecognizer(viewGestureRecognizerForSearchBar)
    searchBar.text = searchTerm
  }

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchTerm = searchBar.text
    searchBar.resignFirstResponder()
    performSearch()
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

  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : Any]) {
    self.filters = filters
    performSearch()
  }
}
