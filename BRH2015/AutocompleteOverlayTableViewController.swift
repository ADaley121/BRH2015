//
//  AutocompleteOverlayTableViewController.swift
//  
//
//  Created by Andrew Daley on 9/19/15.
//
//

import UIKit
import GoogleMaps

protocol AutocompleteOverlayTableViewDelegate {
  func overlayTableViewController(table: AutocompleteOverlayTableViewController, didSelectLocation location: String)
  func overlayTableViewController(table: AutocompleteOverlayTableViewController, searchBarBecameFirstResponder searchBar: UISearchBar)
  func overlayTableViewController(table: AutocompleteOverlayTableViewController, searchBarResignedFirstResponder searchBar: UISearchBar)
}

class AutocompleteOverlayTableViewController: UITableViewController {
  
  var userLocation: CLLocation?
  
  var autocompletes = [NSAttributedString]()
  
  var delegate: AutocompleteOverlayTableViewDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
    tableView.tableHeaderView = searchBar
    searchBar.delegate = self
    searchBar.searchBarStyle = .Minimal
    searchBar.placeholder = "Search"
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Label") as! UITableViewCell
    cell.textLabel?.attributedText = autocompletes[indexPath.row]
    return cell
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return autocompletes.count
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    delegate?.overlayTableViewController(self, didSelectLocation: autocompletes[indexPath.row].string)
  }
}

extension AutocompleteOverlayTableViewController: UISearchBarDelegate {
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if let userLocation = userLocation {
      let ur = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude - 50, longitude: userLocation.coordinate.longitude - 50)
      let bl = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude + 50, longitude: userLocation.coordinate.longitude + 50)
      let bounds = GMSCoordinateBounds(coordinate: ur, coordinate: bl)
      GMSPlacesClient.sharedClient().autocompleteQuery(searchText, bounds: bounds, filter: nil) { places, error in
        if let places = places {
          self.autocompletes = places.map { $0.attributedFullText }
          self.tableView.reloadData()
        }
      }
    }
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.text = ""
    searchBar.resignFirstResponder()
    tableView.reloadData()
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = true
    delegate?.overlayTableViewController(self, searchBarBecameFirstResponder: searchBar)
    return true
  }
  
  func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = false
    delegate?.overlayTableViewController(self, searchBarResignedFirstResponder: searchBar)
    return true
  }
}
