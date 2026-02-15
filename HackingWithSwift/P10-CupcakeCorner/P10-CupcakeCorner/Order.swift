//
//  Order.swift
//  P10-CupcakeCorner
//
//  Created by Michael Gillbanks on 15/02/2026.
//

import Foundation

@Observable
class Order: Codable {
    enum CodingKeys: String, CodingKey {
        case _type = "type"
        case _quantity = "quantity"
        case _specialRequestEnabled = "specialRequestEnabled"
        case _extraFrosting = "extraFrosting"
        case _adddSprinkles = "adddSprinkles"
        case _name = "name"
        case _city = "city"
        case _streetAddress = "streetaddress"
        case _zip = "zip"
    }
    
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    
    var type = 0
    var quantity = 3
    
    var specialRequestEnabled = false {
        didSet {
            if !specialRequestEnabled {
                extraFrosting = false
                adddSprinkles = false
            }
        }
    }
    var extraFrosting = false
    var adddSprinkles = false
    
    var name = ""
    var streetAddress = ""
    var city = ""
    var zip = ""
    
    var hasValidAddress: Bool {
        return !name.isEmpty && !streetAddress.isEmpty && !city.isEmpty && !zip.isEmpty
    }
    
    var cost: Decimal {
        // $2 per cake
        var cost = Decimal(quantity) * 2
        
        // complicated cakes cost more
        cost += Decimal(type) / 2
        
        // $1/cake for extra frosting
        if extraFrosting {
            cost += Decimal(quantity)
        }
        
        // $0.50/cake for  sprinkles
        if adddSprinkles {
            cost += Decimal(quantity) / 2
        }
        
        return cost
    }
}
