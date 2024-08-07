
import SwiftUI
import Combine

class PeopleData: ObservableObject {
    @Published var people: [Person] = []
    @Published var foodItems: [FoodItem] = []
    @Published var percentage: Double = 10.0 // Default percentage
    @Published var phoneNumber: String = "903020101" // Added phone number field

    var totalAmount: Double {
        people.reduce(0) { $0 + $1.totalAmount }
    }

    var totalAmountWithPercentage: Double {
        people.reduce(0) { $0 + $1.totalAmountWithPercentage(percentage) }
    }

    func addPerson(name: String) {
        let newPerson = Person(name: name, items: [])
        people.append(newPerson)
    }

    func addFoodItem(name: String, price: Double) {
        let newFoodItem = FoodItem(name: name, price: price)
        foodItems.append(newFoodItem)
    }

    func assignFoodItem(_ foodItem: FoodItem, to person: Person) {
        if let personIndex = people.firstIndex(where: { $0.id == person.id }) {
            var updatedPerson = people[personIndex]
            updatedPerson.items.append(foodItem)
            people[personIndex] = updatedPerson
        }
    }

    func deleteFoodItem(_ foodItem: FoodItem) {
        if let index = foodItems.firstIndex(where: { $0.id == foodItem.id }) {
            foodItems.remove(at: index)
        }
    }

    func deleteFoodItemFromPerson(_ foodItem: FoodItem, from person: Person) {
        if let personIndex = people.firstIndex(where: { $0.id == person.id }) {
            var updatedPerson = people[personIndex]
            if let itemIndex = updatedPerson.items.firstIndex(where: { $0.id == foodItem.id }) {
                updatedPerson.items.remove(at: itemIndex)
                people[personIndex] = updatedPerson
            }
        }
    }

    func deletePerson(_ person: Person) {
        if let index = people.firstIndex(where: { $0.id == person.id }) {
            people.remove(at: index)
        }
    }
}
