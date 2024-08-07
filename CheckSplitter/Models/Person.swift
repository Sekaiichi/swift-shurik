//
//  Person.swift
//  CheckSplitter
//
//  Created by KhusainovMehrubon on 26/07/24.
//

import Foundation

struct Person: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var items: [FoodItem] = []

    var totalAmount: Double {
        items.reduce(0) { $0 + $1.price }
    }

    func totalAmountWithPercentage(_ percentage: Double) -> Double {
        totalAmount + (totalAmount * percentage / 100)
    }
}

