import SwiftUI

// MARK: - Тема
extension Color {
    static let appBlack = Color(red: 0.04, green: 0.04, blue: 0.06)
    static let appCard = Color(red: 0.09, green: 0.09, blue: 0.11)
    static let appOrange = Color(red: 1.0, green: 0.44, blue: 0.0)
}

// MARK: - Главное приложение
@main
struct AccountingApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Вкладки
struct MainTabView: View {
    var body: some View {
        TabView {
            LessonsView()
                .tabItem { Label("Обучение", systemImage: "book.fill") }
            TrainerTabView()
                .tabItem { Label("Тренажёр", systemImage: "arrow.left.arrow.right") }
            VATView()
                .tabItem { Label("НДС", systemImage: "percent") }
        }
        .tint(.appOrange)
    }
}

// MARK: - Данные
struct Lesson: Identifiable {
    let id = UUID()
    let title: String
    let text: String
}

let lessonsData = [
    Lesson(title: "1. Основы", text: "Бухгалтерский учёт — это система сбора и обобщения информации о хозяйственных операциях."),
    Lesson(title: "2. Счета", text: "Активные: 50 (Касса), 51 (Расчётный счёт). Пассивные: 60 (Поставщики), 70 (Оплата труда)."),
    Lesson(title: "3. Двойная запись", text: "Каждая операция отражается по дебету одного и кредиту другого счёта."),
    Lesson(title: "4. Проводки", text: "Дт 50 Кт 51 (деньги в кассу). Дт 60 Кт 51 (оплата поставщику)."),
    Lesson(title: "5. Отчётность", text: "Баланс и Отчёт о финансовых результатах — главные формы отчётности.")
]

// MARK: - Экран Обучения
struct LessonsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(lessonsData) { lesson in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lesson.title)
                                .font(.headline)
                                .foregroundColor(.appOrange)
                            Text(lesson.text)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding(20)
            }
            .background(Color.appBlack.ignoresSafeArea())
            .navigationTitle("Обучение")
        }
    }
}

// MARK: - Тренажёр
struct Question {
    let scenario: String
    let correctDebit: String
    let correctCredit: String
    let debitOptions: [String]
    let creditOptions: [String]
}

let questionsData = [
    Question(scenario: "Деньги в кассу с расчётного счёта", correctDebit: "50 Касса", correctCredit: "51 Расчётный счёт", debitOptions: ["50 Касса", "51 Расчётный счёт", "60 Поставщики"], creditOptions: ["51 Расчётный счёт", "50 Касса", "70 Оплата"]),
    Question(scenario: "Оплачен счёт поставщику", correctDebit: "60 Поставщики", correctCredit: "51 Расчётный счёт", debitOptions: ["60 Поставщики", "51 Расчётный счёт", "20 Производство"], creditOptions: ["51 Расчётный счёт", "60 Поставщики", "50 Касса"])
]

struct TrainerTabView: View {
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedDebit: String?
    @State private var selectedCredit: String?
    @State private var showResult = false
    
    var q: Question { questionsData[currentIndex] }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Счёт: \(score)").font(.headline).foregroundColor(.appOrange)
                Text(q.scenario).font(.title3).foregroundColor(.white)
                
                Text("Дебет:").foregroundColor(.gray)
                ForEach(q.debitOptions, id: \.self) { opt in
                    Button { selectedDebit = opt } label: {
                        Text(opt).frame(maxWidth: .infinity).padding()
                            .background(selectedDebit == opt ? Color.appOrange : Color.appCard)
                            .foregroundColor(selectedDebit == opt ? .black : .white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                Text("Кредит:").foregroundColor(.gray)
                ForEach(q.creditOptions, id: \.self) { opt in
                    Button { selectedCredit = opt } label: {
                        Text(opt).frame(maxWidth: .infinity).padding()
                            .background(selectedCredit == opt ? Color.appOrange : Color.appCard)
                            .foregroundColor(selectedCredit == opt ? .black : .white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                Button("Проверить") {
                    if selectedDebit == q.correctDebit && selectedCredit == q.correctCredit {
                        score += 1
                    }
                    showResult = true
                }
                .frame(maxWidth: .infinity).padding().background(Color.appOrange).foregroundColor(.black).clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(selectedDebit == nil || selectedCredit == nil)
                
                Spacer()
            }
            .padding(20)
            .background(Color.appBlack.ignoresSafeArea())
            .navigationTitle("Тренажёр")
            .alert("Результат", isPresented: $showResult) {
                Button("Далее") {
                    currentIndex = (currentIndex + 1) % questionsData.count
                    selectedDebit = nil; selectedCredit = nil
                }
            } message: {
                Text("Правильно: Дт \(q.correctDebit) Кт \(q.correctCredit)")
            }
        }
    }
}

// MARK: - НДС
struct VATView: View {
    @State private var amount = ""
    @State private var rate = 20.0
    
    var vat: Double { (Double(amount) ?? 0) * rate / 100 }
    var total: Double { (Double(amount) ?? 0) + vat }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Сумма", text: $amount)
                    .keyboardType(.decimalPad)
                    .padding().background(Color.appCard).clipShape(RoundedRectangle(cornerRadius: 12)).foregroundColor(.white)
                
                Picker("Ставка", selection: $rate) {
                    Text("20%").tag(20.0)
                    Text("10%").tag(10.0)
                    Text("0%").tag(0.0)
                }
                .pickerStyle(.segmented)
                
                Text("НДС: \(String(format: "%.2f", vat)) ₽").foregroundColor(.appOrange)
                Text("Итого: \(String(format: "%.2f", total)) ₽").foregroundColor(.appOrange)
                Spacer()
            }
            .padding(20)
            .background(Color.appBlack.ignoresSafeArea())
            .navigationTitle("НДС")
        }
    }
}
