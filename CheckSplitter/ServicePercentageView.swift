import SwiftUI

struct ServicePercentageView: View {
    @Binding var percentage: Double
    @State private var tempPercentage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Set Service Percentage")) {
                    TextField("Percentage", text: $tempPercentage)
                        .keyboardType(.decimalPad)
                        .onAppear {
                            tempPercentage = String(percentage)
                        }
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    // Dismiss modal
                },
                trailing: Button("Save") {
                    if let newPercentage = Double(tempPercentage) {
                        percentage = newPercentage
                    }
                    // Dismiss modal
                }
            )
        }
    }
}
