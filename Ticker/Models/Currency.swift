//
//  Currency.swift
//  Ticker
//
//  Created by Hayder Al-Husseini on 23/07/2020.
//  Copyright © 2020 kodeba•se ltd.
//
//  See LICENSE.md for licensing information.
//

import Foundation

struct Currency {
    let code: String
    let rate: String
    
    var imageName: String {
        return code.lowercased()
    }
    
    var name: String {
        switch code.lowercased() {
        case "aed":
            return "UAE Dirham"
        case "cad":
            return "Canadian Dollar"
        case "cny":
            return "Yuan Renminbi"
        case "dkk":
            return "Danish Krone"
        case "egp":
            return "Egyptian Pound"
        case "eur":
            return "Euro"
        case "gbp":
            return "Pound Sterling"
        case "inr":
            return "Indian Rupee"
        case "jpy":
            return "Yen"
        case "pln":
            return "Polish Zloty"
        case "rub":
            return "Russian Ruble"
        default:
            return "Unknown curreny"
        }
    }
}
