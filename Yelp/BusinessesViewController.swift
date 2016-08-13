//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
FiltersViewControllerDelegate, UISearchBarDelegate, UIScrollViewDelegate, CLLocationManagerDelegate {

  var viewGestureRecognizerForSearchBar: UITapGestureRecognizer!
  var businesses: [Business]!
  var filters: Filters?
  let searchBar = UISearchBar()
  var searchTerm: String?
  var isLoadingData = false
  var loadingMoreView:InfiniteScrollActivityView?
  var locationManager: CLLocationManager!
  var currentLatLng: CLLocationCoordinate2D?

  @IBOutlet weak var filtersButtonItem: UIBarButtonItem!
  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.distanceFilter = 200
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()

    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120


    self.navigationItem.titleView = searchBar
    searchBar.delegate = self
    searchBar.text = searchTerm
    performSearch()

    viewGestureRecognizerForSearchBar = UITapGestureRecognizer(target: self, action: #selector(BusinessesViewController.onViewTapped))

    // Set up Infinite Scroll loading indicator
    let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
    loadingMoreView = InfiniteScrollActivityView(frame: frame)
    loadingMoreView!.hidden = true
    tableView.addSubview(loadingMoreView!)

    var insets = tableView.contentInset
    insets.bottom += InfiniteScrollActivityView.defaultHeight
    tableView.contentInset = insets
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations[0]
    currentLatLng = location.coordinate
    locationManager.stopUpdatingLocation()
    performSearch()
  }

  func performSearch(callback: (([Business]) -> Void)?) {
    let searchTerm = self.searchTerm ?? ""

    Business.searchWithTerm(searchTerm,
                            sort: filters?.sort,
                            categories: filters?.categories,
                            deals: filters?.deals,
                            latLng: currentLatLng,
                            offset: 0) {
                              (businesses: [Business]!, error: NSError!) in
                              self.businesses = businesses
                              self.tableView.reloadData()

                              if let callback = callback, businesses = businesses {
                                callback(businesses)
                              }
    }
  }

  func performSearch() {
    performSearch(nil)
  }

  func performPagedSearch() {
    let searchTerm = self.searchTerm ?? ""
    guard let offset = businesses?.count else { return }

    // Update position of loadingMoreView, and start loading indicator
    let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
    loadingMoreView?.frame = frame
    loadingMoreView!.startAnimating()

    isLoadingData = true
    Business.searchWithTerm(searchTerm,
                            sort: filters?.sort,
                            categories: filters?.categories,
                            deals: filters?.deals,
                            latLng: currentLatLng,
                            offset: offset) {
                              (businesses: [Business]!, error: NSError!) in
                              self.isLoadingData = false
                              self.loadingMoreView!.stopAnimating()
                              self.businesses.appendContentsOf(businesses)
                              self.tableView.reloadData()
    }
  }

  func scrollViewDidScroll(scrollView: UIScrollView) {
    if isLoadingData { return }
    let bottomEdge = scrollView.contentOffset.y + scrollView.bounds.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
      // we are at the end
      performPagedSearch()

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
    guard let navigationViewController = segue.destinationViewController as? UINavigationController else { return }

    if navigationViewController.topViewController is FiltersViewController {
      let filtersViewController = navigationViewController.topViewController as! FiltersViewController
      filtersViewController.delegate = self
    } else if navigationViewController.topViewController is MapViewController {
      if let mapViewController = navigationViewController.topViewController as? MapViewController {
        mapViewController.businesses = businesses
        
        mapViewController.onClickRefreshCallback = { (latLng: CLLocationCoordinate2D) in
          self.currentLatLng = latLng
          self.performSearch({ (businesses) in
            mapViewController.businesses = businesses
          })
        }
      }
    }
  }
  
  func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: Filters) {
    self.filters = filters
    performSearch()
  }
}
