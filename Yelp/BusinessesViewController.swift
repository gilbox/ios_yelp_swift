//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {

  var viewGestureRecognizerForSearchBar: UITapGestureRecognizer!
  var businesses: [Business]!
  var filters: Filters?
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

    Business.searchWithTerm(searchTerm, sort: filters?.sort, categories: filters?.categories, deals: filters?.deals) {
      (businesses: [Business]!, error: NSError!) in
      self.businesses = businesses
      self.tableView.reloadData()
      for b in businesses {
        print(b.coordinate)
      }
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
    if segue.destinationViewController is UINavigationController {
      if let navigationViewController = segue.destinationViewController as? UINavigationController {
        let filtersViewController = navigationViewController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
      }
    } else if segue.destinationViewController is MapViewController {
      if let mapViewController = segue.destinationViewController as? MapViewController {
        var annotations = [MapAnnotation]()
        for b in businesses {
          let annotation = MapAnnotation(title: b.name ?? "", locationName: b.categories ?? "", coordinate: b.coordinate!)
          annotations.append(annotation)
        }
        mapViewController.mapAnnotations = annotations
      }
    }
  }

  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: Filters) {
    self.filters = filters
    performSearch()
  }
}
