//
//  Item.swift
//  Split
//
//  Created by Nathan Bala on 10/29/19.
//  Copyright © 2019 Nathan Bala. All rights reserved.
//

import Foundation

class Item{
    var itemName: String
    var itemPrice: Float
    var itemAmount: Int
    init(itemName: String, itemPrice: Float, itemAmount: Int) {
        self.itemName = itemName
        self.itemPrice = itemPrice
        self.itemAmount = itemAmount
    }
}
