import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutRecord.timestamp, order: .reverse) private var records: [WorkoutRecord]

    @State private var month = Date().startOfMonth
    @State private var selectedDate = Date()
    @State private var showingAdd = false

    private let calendar = Calendar.current
    private let weekdaySymbols = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    calendarCard
                    dayHeader
                    recordSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("训练日历")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAdd) {
                AddWorkoutView(defaultDate: selectedDate)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("记录训练，也记录身体恢复的时间")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var calendarCard: some View {
        VStack(spacing: 12) {
            HStack {
                Button { month = calendar.date(byAdding: .month, value: -1, to: month)! } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(month.formatted(.dateTime.year().month(.wide)))
                    .font(.headline)
                Spacer()
                Button { month = calendar.date(byAdding: .month, value: 1, to: month)! } label: {
                    Image(systemName: "chevron.right")
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                ForEach(monthCells.indices, id: \.self) { index in
                    if let date = monthCells[index] {
                        dayCell(date)
                    } else {
                        Color.clear.frame(height: 42)
                    }
                }
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func dayCell(_ date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let hasRecord = records.contains { calendar.isDate($0.timestamp, inSameDayAs: date) }

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline.weight(isSelected || isToday ? .semibold : .regular))
                Circle()
                    .fill(hasRecord ? (isSelected ? Color.white : Color.teal) : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(maxWidth: .infinity, minHeight: 42)
            .foregroundStyle(isSelected ? Color.white : (isToday ? Color.teal : Color.primary))
            .background(isSelected ? Color.primary : Color.clear, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var dayHeader: some View {
        HStack {
            Text(calendar.isDateInToday(selectedDate) ? "今天" : selectedDate.formatted(.dateTime.month().day().weekday(.wide)))
                .font(.title3.bold())
            Spacer()
            Button {
                showingAdd = true
            } label: {
                Label("记录训练", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
        }
    }

    private var recordSection: some View {
        let dayRecords = records.filter { calendar.isDate($0.timestamp, inSameDayAs: selectedDate) }
        return Group {
            if dayRecords.isEmpty {
                ContentUnavailableView("这一天还没有训练记录", systemImage: "figure.strengthtraining.traditional", description: Text("点击“记录训练”开始"))
                    .frame(minHeight: 220)
            } else {
                VStack(spacing: 10) {
                    ForEach(dayRecords) { record in
                        WorkoutCard(record: record)
                            .contextMenu {
                                Button(role: .destructive) {
                                    modelContext.delete(record)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }

    private var monthCells: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: month),
              let range = calendar.range(of: .day, in: .month, for: month) else { return [] }
        let first = interval.start
        let weekday = calendar.component(.weekday, from: first)
        let mondayBasedOffset = (weekday + 5) % 7
        var result = Array<Date?>(repeating: nil, count: mondayBasedOffset)
        for day in range {
            result.append(calendar.date(bySetting: .day, value: day, of: first))
        }
        while result.count % 7 != 0 { result.append(nil) }
        return result
    }
}

private struct WorkoutCard: View {
    let record: WorkoutRecord
    @State private var now = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(record.exercise)
                    .font(.headline)
                Spacer()
                Text(elapsedText)
                    .font(.subheadline.bold())
                    .foregroundStyle(.teal)
            }

            Text("记录时间  \(record.timestamp.formatted(date: .omitted, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.secondary)

            if !metrics.isEmpty {
                Text(metrics)
                    .font(.subheadline)
            }

            if !record.note.isEmpty {
                Text(record.note)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                now = Date()
            }
        }
    }

    private var metrics: String {
        var pieces: [String] = []
        if let weight = record.weight { pieces.append("重量 \(weight.formatted()) kg") }
        if let sets = record.sets { pieces.append("组数 \(sets)") }
        if let reps = record.reps { pieces.append("次数 \(reps)") }
        return pieces.joined(separator: "   ")
    }

    private var elapsedText: String {
        let totalMinutes = max(0, Int(now.timeIntervalSince(record.timestamp) / 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours < 24 {
            return "已过去 \(hours)小时\(minutes)分钟"
        }
        return "已过去 \(hours / 24)天\(hours % 24)小时\(minutes)分钟"
    }
}

private extension Date {
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }
}
