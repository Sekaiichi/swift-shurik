//
//  FoodItem.swift
//  CheckSplitter
//
//  Created by KhusainovMehrubon on 26/07/24.
//

import Foundation

struct FoodItem: Identifiable, Hashable, Codable {
    let id = UUID()
    var name: String
    var price: Double
    // Добавляем поле quantity, если оно потребуется
    var quantity: Double?
}
