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
    
    var name: String {
        didSet {
            UserDefaults.standard.set(name, forKey: "name")
        }
    }
    var streetAddress: String {
        didSet {
            UserDefaults.standard.set(streetAddress, forKey: "streetAddress")
        }
    }
    var city: String {
        didSet {
            UserDefaults.standard.set(city, forKey: "city")
        }
    }
    var zip: String {
        didSet {
            UserDefaults.standard.set(zip, forKey: "zip")
        }
    }
    
    var hasValidAddress: Bool {
        return validAddress(name: name, streetAddress: streetAddress, city: city, zip: zip)
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
    
    func validAddress(name: String, streetAddress: String, city: String, zip: String) -> Bool {
        let notEmpty: Bool = !name.isEmpty && !streetAddress.isEmpty && !city.isEmpty && !zip.isEmpty
        let notWhitespace: Bool = isntJustWhitespace(string: name) && isntJustWhitespace(string: streetAddress) && isntJustWhitespace(string: city) && isntJustWhitespace(string: zip)
        return notEmpty && notWhitespace
    }
    
    func isntJustWhitespace(string: String) -> Bool {
        for character in string {
            if !character.isWhitespace {
                return true
            }
        }
        return false
    }
    
    init() {
        name = UserDefaults.standard.string(forKey: "name") ?? ""
        streetAddress = UserDefaults.standard.string(forKey: "streetAddress") ?? ""
        city = UserDefaults.standard.string(forKey: "city") ?? ""
        zip = UserDefaults.standard.string(forKey: "zip") ?? ""
    }
}
