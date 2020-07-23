//
//  ViewController.swift
//  Ticker
//
//  Created by Hayder Al-Husseini on 02/07/2020.
//  Copyright © 2020 kodeba•se ltd.
//
//  See LICENSE.md for licensing information.
//

import UIKit

class ViewController: UIViewController {
    private struct Constants {
        struct Segue {
            static let ticker = "ticker"
        }
    }

    @IBOutlet weak var tickerViewHeightConstraint: NSLayoutConstraint!
    private weak var tickerViewController: TickerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTickerViewLayout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.ticker {
            tickerViewController = segue.destination as? TickerViewController
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // If the ticker was in a stack view.
        // make this call from within TickerViewController
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            updateTickerViewLayout()
        }
    }
    
    private func updateTickerViewLayout() {
        guard let tickerViewController = tickerViewController else {
            return
        }
        tickerViewHeightConstraint.constant = tickerViewController.recommendedHeight
    }
}
