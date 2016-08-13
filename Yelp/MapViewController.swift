//
//  MapViewController.swift
//  Yelp
//
//  Created by Gil Birman on 8/10/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!

  var mapAnnotations: [MapAnnotation]?
  var businesses: [Business]! {
    didSet {
      if let mapAnnotations = mapAnnotations {
        mapView.removeAnnotations(mapAnnotations)
      }
      var annotations = [MapAnnotation]()
      for b in businesses {
        let annotation = MapAnnotation(title: b.name ?? "", locationName: b.categories ?? "", coordinate: b.coordinate!)
        annotations.append(annotation)
      }
      mapAnnotations = annotations
      if let mapAnnotations = mapAnnotations, mapView = mapView {
        mapView.showAnnotations(mapAnnotations, animated: false)
      }
    }
  }

  var onClickRefreshCallback: ((CLLocationCoordinate2D) -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()

    mapView.delegate = self

    if let mapAnnotations = mapAnnotations {
      mapView.showAnnotations(mapAnnotations, animated: false)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func onRefresh(sender: AnyObject) {
    print("refresh")
    onClickRefreshCallback?(mapView.centerCoordinate)
  }

  @IBAction func onList(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    if let annotation = annotation as? MapAnnotation {
      let identifier = "pin"
      var view: MKPinAnnotationView
      if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        as? MKPinAnnotationView {
        dequeuedView.annotation = annotation
        view = dequeuedView
      } else {
        view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
      }
      return view
    }
    return nil
  }
}
