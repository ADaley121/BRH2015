//
//  AutocompleteOverlayView.swift
//  
//
//  Created by Andrew Daley on 9/19/15.
//
//

import UIKit

protocol AutocompleteOverlayViewDelegate {
  func overlay(overlay: AutocompleteOverlayView, selectedLocation location: String)
  func overlayDismissed(overlay: AutocompleteOverlayView)
}

class AutocompleteOverlayView: UIView {
  
  let tableController: AutocompleteOverlayTableViewController
  
  var blurView: UIVisualEffectView?
  
  var delegate: AutocompleteOverlayViewDelegate?
  
  // MARK: Initializers
  
  override init(frame: CGRect) {
    tableController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Overlay") as! AutocompleteOverlayTableViewController
    tableController.tableView.frame = frame.rectByInsetting(dx: frame.width / 16, dy: frame.height * 0.28)
    tableController.tableView.layer.cornerRadius = 8.0
    super.init(frame: frame)
    tableController.delegate = self
    addSubview(tableController.tableView)
    bringSubviewToFront(tableController.tableView)
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissView:")
    gestureRecognizer.delegate = self
    addGestureRecognizer(gestureRecognizer)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func animateInnerFrame() {
    tableController.tableView.transform = CGAffineTransformMakeScale(0.1, 0.1)
    UIView.animateWithDuration(0.15, delay: 0, options: .CurveEaseOut,
      animations: {
        self.tableController.tableView.transform = CGAffineTransformIdentity
      },
      completion: nil
    )
  }
  
  /// Animates the blurView to fade in.
  private func animateBlur() {
    if objc_getClass("UIVisualEffectView") != nil {
      blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
      blurView!.frame = frame
      blurView!.autoresizingMask = .FlexibleWidth | .FlexibleHeight
      backgroundColor = UIColor.clearColor()
      blurView!.alpha = 0.0
      UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut,
        animations: {
          self.blurView!.alpha = 1.0
          self.addSubview(self.blurView!)
          self.bringSubviewToFront(self.tableController.tableView)
        },
        completion: nil
      )
    }
  }
  
  func animateInto(view: UIView) {
    animateBlur()
    animateInnerFrame()
    view.addSubview(self)
    view.bringSubviewToFront(self)
  }
  
  func animateOut() {
    alpha = 1.0
    UIView.animateWithDuration(0.15, delay: 0.0, options: .CurveEaseInOut,
      animations: {
        self.alpha = 0.0
      },
      completion: { _ in
        self.removeFromSuperview()
      }
    )
  }
  
  func dismissView(sender: UITapGestureRecognizer) {
    delegate?.overlayDismissed(self)
  }
}

// MARK: - BoardOverlayTableViewControllerDelegate

extension AutocompleteOverlayView: AutocompleteOverlayTableViewDelegate {
  
  /// Forwards the passed back board to the delegate of this class.
  ///
  /// :param: table The controller that is passing a board back to this overlay.
  /// :param: board The board that is being passed back.
  func overlayTableViewController(table: AutocompleteOverlayTableViewController, didSelectLocation location: String) {
    delegate?.overlay(self, selectedLocation: location)
  }
  
  func overlayTableViewController(table: AutocompleteOverlayTableViewController, searchBarBecameFirstResponder searchBar: UISearchBar) {
    let center = (frame.height - 256 + 30) / 2
    let offset = center - tableController.tableView.frame.midY
    UIView.animateWithDuration(0.1) {
      self.tableController.tableView.frame.offset(dx: 0, dy: offset)
    }
  }
  
  func overlayTableViewController(table: AutocompleteOverlayTableViewController, searchBarResignedFirstResponder searchBar: UISearchBar) {
    let center = frame.height / 2
    let offset = center - tableController.tableView.frame.midY
    UIView.animateWithDuration(0.1) {
      self.tableController.tableView.frame.offset(dx: 0, dy: offset)
    }
  }
  
}

// MARK: UIGestureRecognizerDelegate

extension AutocompleteOverlayView: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    return touch.view == blurView || touch.view == self
  }
}

