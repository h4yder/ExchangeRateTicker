//
//  ForexService.swift
//  Ticker
//
//  Created by Hayder Al-Husseini on 06/07/2020.
//  Copyright © 2020 kodeba•se ltd.
//
//  See LICENSE.md for licensing information.
//

import Foundation

class ForexService {
    private struct Constants {
        // Get an appId from https://docs.openexchangerates.org/docs/authentication
        static let appId = ""
        static let latestPricesAPI = "https://openexchangerates.org/api/latest.json"
    }
    
    func latestPrices(completion: @escaping ([Currency])->Void) {
        guard !Constants.appId.isEmpty else {
            if let cachePath = Bundle.main.url(forResource: "cache", withExtension: "json"),
                let data = try? Data(contentsOf: cachePath) {
                print("Using cached data, rates pulled on 23 July 2020")
                let currencies = self.parse(data)
                completion(currencies)
            }
            
            return
        }
        
        let urlString = Constants.latestPricesAPI + "?app_id=\(Constants.appId)"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            let currencies = self.parse(data)
            DispatchQueue.main.async {
                completion(currencies)
            }
        }.resume()
    }
    
    private func parse(_ data: Data?) -> [Currency] {
        guard let data = data,
            let payload = try? JSONDecoder().decode(Rates.self, from: data) else {
                return []
        }
        
        return payload.rates.map { Currency(code: $0.key, rate: String(format:"%1.4f",$0.value)) }
    }
    
    private struct CodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
    }
    
    private struct Rates: Decodable {
        let rates: [String: Float]
        
        init(from decoder: Decoder) throws {
            guard let resultsKey = CodingKeys(stringValue: "rates") else {
                rates = [:]
                return
            }
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            rates = try container.decode([String: Float].self, forKey: resultsKey)
        }
    }
}
