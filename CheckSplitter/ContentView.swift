import SwiftUI
import Combine
import UIKit

struct ContentView: View {
    @StateObject var peopleData = PeopleData()
    @State private var newPersonName = ""
    @State private var newFoodName = ""
    @State private var newFoodPrice = ""
    @State private var selectedPeople: Set<UUID> = []
    @State private var selectedFoodItems: Set<UUID> = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showNotification = false
    @State private var notificationMessage = ""
    @State private var isLoading = false
    @State private var showServicePercentageSheet = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showEditFoodItemModal = false
    @State private var foodItemToEdit: FoodItem?
    @State private var showEditPhoneNumberSheet = false
    @State private var scrollViewProxy: ScrollViewProxy? = nil

    var body: some View {
        NavigationView {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 20) {
                            headerSection
                            cameraButtonSection
                            addFoodItemSection
                            addPersonSection
                                .id("addPersonSection")
                            assignFoodItemsSection
                            totalBillSection
                                .id("totalBillSection")
                        }
                        .padding()
                        .onAppear {
                            scrollViewProxy = proxy
                        }
                        .onChange(of: isLoading) { _ in
                            if !isLoading {
                                withAnimation {
                                    proxy.scrollTo("addPersonSection", anchor: .top)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("")
                .navigationBarHidden(true)
                
                if isLoading {
                    loadingView
                }
                
                if showNotification {
                    notificationView
                }
            }
            .sheet(isPresented: $showServicePercentageSheet) {
                ServicePercentageSheet(percentage: $peopleData.percentage)
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, onImagePicked: uploadReceiptImage)
            }
            .sheet(item: $foodItemToEdit) { foodItem in
                EditFoodItemSheet(foodItem: foodItem, onSave: saveEditedFoodItem)
            }
            .sheet(isPresented: $showEditPhoneNumberSheet) {
                EditPhoneNumberSheet(phoneNumber: $peopleData.phoneNumber)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 20) {
            Text("Лучший способ разделить счет")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            
            Text("Разделите свой счет и делитесь им с друзьями легко, просто отсканировав свой счет.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }

    private var cameraButtonSection: some View {
        VStack {
            Button(action: {
                showImagePicker = true
            }) {
                Image(systemName: "camera.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
        }
    }

    private var addPersonSection: some View {
        SectionView(title: "Добавить нового человека") {
            VStack(spacing: 10) {
                TextField("Введите имя", text: $newPersonName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                Button(action: addPerson) {
                    Text("Добавить")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("ОК")))
                }
            }
            .padding()
        }
    }

    private var addFoodItemSection: some View {
        SectionView(title: "Добавить блюдо") {
            VStack(spacing: 10) {
                TextField("Введите название блюда", text: $newFoodName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                TextField("Введите цену", text: $newFoodPrice)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.decimalPad)
                Button(action: addFoodItem) {
                    Text("Добавить блюдо")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.teal]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Ошибка"), message: Text(alertMessage), dismissButton: .default(Text("ОК")))
                }
            }
            .padding()
        }
    }

    private var assignFoodItemsSection: some View {
        SectionView(title: "Назначить блюда") {
            VStack(spacing: 10) {
                Text("Выберите людей")
                    .font(.headline)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(peopleData.people) { person in
                        PersonTagView(person: person, isSelected: selectedPeople.contains(person.id)) {
                            toggleSelection(of: person.id, in: &selectedPeople)
                        }
                    }
                }
                Text("Выберите блюда")
                    .font(.headline)
                LazyVStack(spacing: 10) {
                    ForEach(peopleData.foodItems) { foodItem in
                        FoodItemRow(foodItem: foodItem, isSelected: selectedFoodItems.contains(foodItem.id)) {
                            toggleSelection(of: foodItem.id, in: &selectedFoodItems)
                        } onEdit: {
                            foodItemToEdit = foodItem
                        } onDelete: {
                            peopleData.deleteFoodItem(foodItem)
                        }
                    }
                }
                Button(action: assignFoodItems) {
                    Text("Назначить выбранным")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding()
        }
    }

    private var totalBillSection: some View {
        SectionView(title: "Общий счет") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button(action: {
                        showEditPhoneNumberSheet = true
                    }) {
                        Text(peopleData.phoneNumber)
                            .underline()
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Button(action: {
                        showServicePercentageSheet = true
                    }) {
                        Text("+\(peopleData.percentage, specifier: "%.2f")%")
                            .underline()
                            .foregroundColor(.blue)
                    }
                }
                ForEach($peopleData.people) { $person in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(person.name)
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                peopleData.deletePerson(person)
                            }) {
                                Image(systemName: "trash")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                        }
                        Divider() // Горизонтальная линия после имени
                        ForEach(person.items) { item in
                            HStack {
                                Text("\(item.name) - \(item.price, specifier: "%.2f")")
                                Spacer()
                                Button(action: {
                                    peopleData.deleteFoodItemFromPerson(item, from: person)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        Divider() // Горизонтальная линия после всех позиций блюд
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Итого: \(person.totalAmount, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.black) // Изменен цвет на черный
                                Text("Итого + \(peopleData.percentage, specifier: "%.2f")%: \(person.totalAmountWithPercentage(peopleData.percentage), specifier: "%.2f")")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.black) // Изменен цвет на черный
                            }
                            Spacer()
                            Button(action: {
                                shareBill(for: person)
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.bottom, 10)
                }
                VStack(spacing: 10) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Итого: \(peopleData.totalAmount, specifier: "%.2f")")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.black) // Изменен цвет на черный
                            Text("Итого + \(peopleData.percentage, specifier: "%.2f")%: \(peopleData.totalAmountWithPercentage, specifier: "%.2f")")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.black) // Изменен цвет на черный
                        }
                        Spacer()
                        Button(action: {
                            shareTotalBill()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func shareBill(for person: Person) {
        let phoneNumber = peopleData.phoneNumber
        let totalAmountWithPercentage = person.totalAmountWithPercentage(peopleData.percentage)
        let formattedTotalAmountWithPercentage = String(format: "%.2f", totalAmountWithPercentage)
        let link = "https://alifmobi.page.link/toMobi?account=\(phoneNumber)&amount=\(formattedTotalAmountWithPercentage)"
        
        var text = """
        ******************************
        Счет для \(person.name):
        ******************************
        """
        
        for item in person.items {
            text += "\n\(item.name.padding(toLength: 20, withPad: " ", startingAt: 0)) \(String(format: "%.2f", item.price).padding(toLength: 8, withPad: " ", startingAt: 0))"
        }
        
        text += """
        
        ******************************
        Итого: \(String(format: "%.2f", person.totalAmount))
        Итого + \(String(format: "%.2f", peopleData.percentage))%: \(formattedTotalAmountWithPercentage)
        ******************************
        \(link)
        """

        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }

    private func shareTotalBill() {
        let phoneNumber = peopleData.phoneNumber
        let totalAmountWithPercentage = peopleData.totalAmountWithPercentage
        let formattedTotalAmountWithPercentage = String(format: "%.2f", totalAmountWithPercentage)
        
        var text = """
        ******************************
        Общий счет:
        ******************************
        """
        
        for person in peopleData.people {
            let personTotalAmountWithPercentage = person.totalAmountWithPercentage(peopleData.percentage)
            let formattedPersonTotalAmountWithPercentage = String(format: "%.2f", personTotalAmountWithPercentage)
            let personLink = "https://alifmobi.page.link/toMobi?account=\(phoneNumber)&amount=\(formattedPersonTotalAmountWithPercentage)"
            
            text += """
            
            \(person.name)
            ---------------------------
            """
            for item in person.items {
                text += "\n\(item.name.padding(toLength: 20, withPad: " ", startingAt: 0)) \(String(format: "%.2f", item.price).padding(toLength: 8, withPad: " ", startingAt: 0))"
            }
            text += """
            
            ---------------------------
            Итого: \(String(format: "%.2f", person.totalAmount))
            Итого + \(String(format: "%.2f", peopleData.percentage))%: \(formattedPersonTotalAmountWithPercentage)
            \(personLink)
            
            """
        }
        
        text += """
        
        ******************************
        Общий итог: \(String(format: "%.2f", peopleData.totalAmount))
        Общий итог + \(String(format: "%.2f", peopleData.percentage))%: \(formattedTotalAmountWithPercentage)
        ******************************
        """

        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }

    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            ProgressView("Загрузка...")
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
        }
    }

    private var notificationView: some View {
        VStack {
            Spacer()
            Text(notificationMessage)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut)
        }
    }

    private func showNotificationMessage(_ message: String) {
        notificationMessage = message
        showNotification = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showNotification = false
        }
    }

    private func addPerson() {
        if newPersonName.count > 1 {
            if !peopleData.people.contains(where: { $0.name.lowercased() == newPersonName.lowercased() }) {
                withAnimation {
                    peopleData.addPerson(name: newPersonName)
                }
                newPersonName = ""
                showNotificationMessage("Человек добавлен успешно!")
            } else {
                alertMessage = "Человек с таким именем уже существует."
                showingAlert = true
            }
        } else {
            alertMessage = "Имя должно содержать больше одного символа."
            showingAlert = true
        }
    }

    private func addFoodItem() {
        if let price = Double(newFoodPrice), price > 0, newFoodName.count > 1 {
            if !peopleData.foodItems.contains(where: { $0.name.lowercased() == newFoodName.lowercased() }) {
                withAnimation {
                    peopleData.addFoodItem(name: newFoodName, price: price)
                }
                newFoodName = ""
                newFoodPrice = ""
                showNotificationMessage("Блюдо добавлено успешно!")
            } else {
                alertMessage = "Блюдо с таким названием уже существует."
                showingAlert = true
            }
        } else {
            alertMessage = "Некорректное название блюда или цена."
            showingAlert = true
        }
    }

    private func assignFoodItems() {
        for personID in selectedPeople {
            if let person = peopleData.people.first(where: { $0.id == personID }) {
                for foodItemID in selectedFoodItems {
                    if let foodItem = peopleData.foodItems.first(where: { $0.id == foodItemID }) {
                        peopleData.assignFoodItem(foodItem, to: person)
                    }
                }
            }
        }
        selectedPeople.removeAll()
        selectedFoodItems.removeAll()
        showNotificationMessage("Блюда успешно назначены!")
    }

    private func toggleSelection(of id: UUID, in set: inout Set<UUID>) {
        if set.contains(id) {
            set.remove(id)
        } else {
            set.insert(id)
        }
    }

    private func uploadReceiptImage(_ image: UIImage?) {
        guard let image = image else { return }
        let url = URL(string: "https://prod-storage-service.alifshop.tj/shurik")!
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"receipt_image\"; filename=\"receipt_image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(image.jpegData(compressionQuality: 0.8)!)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    alertMessage = "Не удалось загрузить изображение"
                    showingAlert = true
                }
                return
            }
            do {
                print("Response Data: \(String(data: data, encoding: .utf8) ?? "No Data")")
                let decoder = JSONDecoder()
                // Игнорируем дополнительные поля
                decoder.keyDecodingStrategy = .useDefaultKeys
                let foodItems = try decoder.decode([FoodItem].self, from: data)
                DispatchQueue.main.async {
                    withAnimation {
                        peopleData.foodItems.append(contentsOf: foodItems)
                    }
                    showNotificationMessage("Блюда добавлены с фото!")
                    withAnimation {
                        scrollToAddPersonSection()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "Не удалось декодировать ответ: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }.resume()
    }

    private func saveEditedFoodItem(_ updatedFoodItem: FoodItem) {
        if let index = peopleData.foodItems.firstIndex(where: { $0.id == updatedFoodItem.id }) {
            peopleData.foodItems[index] = updatedFoodItem
        }
    }

    private func scrollToAddPersonSection() {
        withAnimation {
            scrollViewProxy?.scrollTo("addPersonSection", anchor: .top)
        }
    }
}

struct CustomButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let foregroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
            .shadow(radius: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.bottom, 5)
            content
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct ServicePercentageSheet: View {
    @Binding var percentage: Double
    @State private var localPercentage: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                TextField("Введите процент обслуживания", text: $localPercentage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .padding()
                Button("Применить") {
                    if let value = Double(localPercentage) {
                        percentage = value
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .buttonStyle(CustomButtonStyle(backgroundColor: .purple, foregroundColor: .white))
                Spacer()
            }
            .navigationTitle("Изменить процент обслуживания")
            .navigationBarItems(trailing: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            localPercentage = String(format: "%.2f", percentage)
        }
    }
}

struct EditPhoneNumberSheet: View {
    @Binding var phoneNumber: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                TextField("Введите номер телефона", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                    .padding()
                Button("Сохранить") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(CustomButtonStyle(backgroundColor: .blue, foregroundColor: .white))
                Spacer()
            }
            .padding()
            .navigationTitle("Редактировать номер телефона")
            .navigationBarItems(trailing: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct PersonTagView: View {
    let person: Person
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(person.name)
                    .foregroundColor(.black)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(10)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
            .cornerRadius(20)
        }
    }
}

struct FoodItemRow: View {
    let foodItem: FoodItem
    let isSelected: Bool
    let action: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding(6)
                    .background(Color.red.opacity(0.2))
                    .clipShape(Circle())
                    .foregroundColor(.red)
            }
            .padding(.trailing, 5)
            
            Button(action: action) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(foodItem.name)
                            .font(.headline)
                            .foregroundColor(isSelected ? .blue : .primary)
                        Text("\(foodItem.price, specifier: "%.2f") руб")
                            .font(.subheadline)
                            .foregroundColor(isSelected ? .blue : .gray)
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .frame(maxWidth: .infinity)
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding(6)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Circle())
                    .foregroundColor(.blue)
            }
            .padding(.leading, 5)
        }
        .padding(.vertical, 5)
    }
}

struct EditFoodItemSheet: View {
    @State var foodItem: FoodItem
    var onSave: (FoodItem) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                TextField("Название блюда", text: $foodItem.name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                TextField("Цена", value: $foodItem.price, formatter: NumberFormatter())
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.decimalPad)
                Button("Сохранить") {
                    onSave(foodItem)
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(CustomButtonStyle(backgroundColor: .blue, foregroundColor: .white))
                Spacer()
            }
            .padding()
            .navigationTitle("Редактировать блюдо")
            .navigationBarItems(trailing: Button("Отмена") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// ImagePicker view modifier
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImagePicked: (UIImage?) -> Void
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
                parent.onImagePicked(selectedImage)
            } else {
                parent.onImagePicked(nil)
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImagePicked(nil)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

extension View {
    func imagePicker(isPresented: Binding<Bool>, image: Binding<UIImage?>, onImagePicked: @escaping (UIImage?) -> Void) -> some View {
        ImagePicker(image: image, onImagePicked: onImagePicked)
            .sheet(isPresented: isPresented) {
                ImagePicker(image: image, onImagePicked: onImagePicked)
            }
    }
}

