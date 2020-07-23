//
//  CurrencyViewAccessibilityElement.swift
//  Ticker
//
//  Created by Hayder Al-Husseini on 23/07/2020.
//  Copyright © 2020 kodeba•se ltd.
//
//  See LICENSE.md for licensing information.
//

import UIKit

class CurrencyViewAccessibilityElement: UIAccessibilityElement {
    let currency: Currency
    
    init(accessibilityContainer container: Any, currency: Currency) {
        self.currency = currency
        super.init(accessibilityContainer: container)
    }
    
    override var accessibilityLabel: String? {
        get {
            let currencyName = currency.name
            let rate = currency.rate
            return "One \(currencyName) is \(rate) to the US Dollar"
        }
        
        set {
            super.accessibilityLabel = newValue
        }
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return .summaryElement
        }
        
        set {
            super.accessibilityTraits = newValue
        }
    }
}
