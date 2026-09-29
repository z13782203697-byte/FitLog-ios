import SwiftUI
import SwiftData

struct AddWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let defaultDate: Date

    @State private var exercise = ""
    @State private var weight = ""
    @State private var sets = ""
    @State private var reps = ""
    @State private var note = ""
    @State private var timestamp: Date

    private let quickItems = ["胸", "背", "腿", "肩", "二头", "三头", "跑步", "卧推", "深蹲", "硬拉"]

    init(defaultDate: Date) {
        self.defaultDate = defaultDate
        let cal = Calendar.current
        let now = Date()
        let time = cal.dateComponents([.hour, .minute], from: now)
        var dateParts = cal.dateComponents([.year, .month, .day], from: defaultDate)
        dateParts.hour = cal.isDateInToday(defaultDate) ? time.hour : 18
        dateParts.minute = cal.isDateInToday(defaultDate) ? time.minute : 0
        _timestamp = State(initialValue: cal.date(from: dateParts) ?? defaultDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("训练项目") {
                    TextField("例如：卧推 / 深蹲 / 跑步", text: $exercise)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(quickItems, id: \.self) { item in
                                Button(item) { exercise = item }
                                    .buttonStyle(.bordered)
                            }
                        }
                    }
                }

                Section("训练数据") {
                    TextField("重量 kg", text: $weight).keyboardType(.decimalPad)
                    TextField("组数", text: $sets).keyboardType(.numberPad)
                    TextField("次数", text: $reps).keyboardType(.numberPad)
                }

                Section("时间") {
                    DatePicker("记录时间", selection: $timestamp, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                }

                Section("备注") {
                    TextField("可选", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("记录训练")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(exercise.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let item = WorkoutRecord(
            timestamp: timestamp,
            exercise: exercise.trimmingCharacters(in: .whitespacesAndNewlines),
            weight: Double(weight),
            sets: Int(sets),
            reps: Int(reps),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(item)
        dismiss()
    }
}
