import Foundation
import SwiftData

// MARK: - Data Service (abstraction over SwiftData)
@MainActor
final class DataService: ObservableObject {
    static let shared = DataService()

    private init() {}

    // MARK: - Today's Log
    func fetchOrCreateTodayLog(context: ModelContext) -> DailyLog {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date == today }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let newLog = DailyLog(date: today)
        context.insert(newLog)
        return newLog
    }

    // MARK: - Weight History (last N days)
    func fetchWeightHistory(context: ModelContext, days: Int = 30) -> [WeightEntry] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<WeightEntry>(
            predicate: #Predicate { $0.date >= cutoff },
            sortBy: [SortDescriptor(\.date)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Macro entries for today
    func fetchTodayMacros(context: ModelContext) -> [MacroEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<MacroEntry>(
            predicate: #Predicate { $0.date == today },
            sortBy: [SortDescriptor(\.date)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Today's habits
    func fetchOrCreateTodayHabits(context: ModelContext) -> HabitEntry {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<HabitEntry>(
            predicate: #Predicate { $0.date == today }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let entry = HabitEntry(date: today)
        context.insert(entry)
        return entry
    }

    // MARK: - Adherence history (last 30 days)
    func fetchAdherenceHistory(context: ModelContext) -> [(date: Date, score: Int)] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date >= cutoff },
            sortBy: [SortDescriptor(\.date)]
        )
        let logs = (try? context.fetch(descriptor)) ?? []
        return logs.map { ($0.date, $0.adherenceScore) }
    }

    // MARK: - Average stats (last 7 days)
    func fetchWeeklyAverages(context: ModelContext) -> WeeklyAverages {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { $0.date >= cutoff }
        )
        let logs = (try? context.fetch(descriptor)) ?? []
        guard !logs.isEmpty else { return WeeklyAverages() }

        let count = Double(logs.count)
        return WeeklyAverages(
            calories: Int(logs.reduce(0) { $0 + $1.calories } / Int(count)),
            proteinG: logs.reduce(0) { $0 + $1.proteinG } / count,
            carbsG: logs.reduce(0) { $0 + $1.carbsG } / count,
            fatG: logs.reduce(0) { $0 + $1.fatG } / count,
            steps: Int(logs.reduce(0) { $0 + $1.steps } / Int(count)),
            waterL: logs.reduce(0) { $0 + $1.waterL } / count,
            sleepHours: logs.reduce(0) { $0 + $1.sleepHours } / count,
            adherenceScore: Int(logs.reduce(0) { $0 + $1.adherenceScore } / Int(count)),
            workoutDays: logs.filter { $0.workoutCompleted }.count
        )
    }

    // MARK: - Save
    func save(context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("SwiftData save error: \(error)")
        }
    }
}

// MARK: - Weekly Averages Model
struct WeeklyAverages {
    var calories: Int = 0
    var proteinG: Double = 0
    var carbsG: Double = 0
    var fatG: Double = 0
    var steps: Int = 0
    var waterL: Double = 0
    var sleepHours: Double = 0
    var adherenceScore: Int = 0
    var workoutDays: Int = 0
}

// MARK: - CSV Export
struct DataExporter {
    static func exportCSV(logs: [DailyLog], weights: [WeightEntry]) -> String {
        var csv = "Date,Weight(kg),Calories,Protein(g),Carbs(g),Fat(g),Steps,Water(L),Sleep(hrs),Workout,Cardio(min),Adherence\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for log in logs {
            let weight = weights.first(where: {
                Calendar.current.isDate($0.date, inSameDayAs: log.date)
            })?.weightKg ?? 0

            csv += "\(dateFormatter.string(from: log.date)),"
            csv += "\(weight == 0 ? "" : String(format: "%.1f", weight)),"
            csv += "\(log.calories),"
            csv += "\(String(format: "%.1f", log.proteinG)),"
            csv += "\(String(format: "%.1f", log.carbsG)),"
            csv += "\(String(format: "%.1f", log.fatG)),"
            csv += "\(log.steps),"
            csv += "\(String(format: "%.1f", log.waterL)),"
            csv += "\(String(format: "%.1f", log.sleepHours)),"
            csv += "\(log.workoutCompleted ? "Yes" : "No"),"
            csv += "\(log.cardioMinutes),"
            csv += "\(log.adherenceScore)\n"
        }

        return csv
    }

    static func exportURL(csv: String) -> URL? {
        let filename = "cutcoach_export_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("Export error: \(error)")
            return nil
        }
    }
}

// MARK: - Streak Calculator
struct StreakCalculator {
    static func currentStreak(logs: [DailyLog], minimumAdherence: Int = 50) -> Int {
        let sorted = logs.sorted { $0.date > $1.date }
        var streak = 0
        var checkDate = Calendar.current.startOfDay(for: Date())

        for log in sorted {
            let logDate = Calendar.current.startOfDay(for: log.date)
            if logDate == checkDate && log.adherenceScore >= minimumAdherence {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else if logDate < checkDate {
                break
            }
        }
        return streak
    }

    static func longestStreak(logs: [DailyLog], minimumAdherence: Int = 50) -> Int {
        let sorted = logs.sorted { $0.date < $1.date }.filter { $0.adherenceScore >= minimumAdherence }
        guard !sorted.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for i in 1..<sorted.count {
            let prev = Calendar.current.startOfDay(for: sorted[i-1].date)
            let curr = Calendar.current.startOfDay(for: sorted[i].date)
            let diff = Calendar.current.dateComponents([.day], from: prev, to: curr).day ?? 0

            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else if diff > 1 {
                current = 1
            }
        }
        return longest
    }
}

// MARK: - Calorie Deficit Calculator
struct DeficitCalculator {
    // Mifflin-St Jeor for males
    static func bmr(weightKg: Double, heightCm: Double, ageYears: Int) -> Double {
        (10 * weightKg) + (6.25 * heightCm) - (5 * Double(ageYears)) + 5
    }

    static func tdee(weightKg: Double, heightCm: Double, ageYears: Int, activityMultiplier: Double = 1.55) -> Double {
        bmr(weightKg: weightKg, heightCm: heightCm, ageYears: ageYears) * activityMultiplier
    }

    static func dailyDeficit(tdee: Double, consumed: Double) -> Double {
        tdee - consumed
    }

    static func projectedWeightLoss(deficitPerDay: Double, days: Int) -> Double {
        // 7700 kcal ≈ 1kg fat
        (deficitPerDay * Double(days)) / 7700
    }

    static func recommendedCalories(weightKg: Double, heightCm: Double, ageYears: Int, deficitGoal: Double = 700) -> ClosedRange<Int> {
        let tdeeVal = tdee(weightKg: weightKg, heightCm: heightCm, ageYears: ageYears)
        let target = tdeeVal - deficitGoal
        let lower = Int(target - 100)
        let upper = Int(target + 100)
        return lower...upper
    }
}
