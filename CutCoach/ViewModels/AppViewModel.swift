import SwiftUI
import Combine
import Foundation

// MARK: - App ViewModel
@MainActor
class AppViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var showCheckIn: Bool = false
    @Published var showAddFood: Bool = false
    @Published var toastMessage: String? = nil
    @Published var todayLog: DailyLog = DailyLog()

    // In-memory state (would be backed by SwiftData in real impl)
    @Published var weightHistory: [WeightEntry] = AppViewModel.sampleWeightHistory()
    @Published var habitStreaks: [String: Int] = [:]
    @Published var currentProfile: UserProfile = UserProfile()

    private var toastTimer: Timer?

    init() {
        generateSampleData()
    }

    // MARK: - Adherence Score
    func computeAdherence(log: DailyLog) -> Int {
        var score = 0
        let protein = log.proteinG
        let calories = log.calories
        let steps = log.steps
        let water = log.waterL
        let sleep = log.sleepHours

        if calories >= 1700 && calories <= 2100 { score += 20 }
        else if calories > 0 { score += 10 }

        if protein >= 150 { score += 25 }
        else if protein >= 120 { score += 12 }

        if steps >= 10000 { score += 20 }
        else if steps >= 7000 { score += 10 }

        if water >= 4.0 { score += 15 }
        else if water >= 2.5 { score += 8 }

        if sleep >= 7 { score += 10 }
        else if sleep >= 6 { score += 5 }

        if log.workoutCompleted { score += 10 }

        return min(score, 100)
    }

    // MARK: - AI Coach Feedback
    func coachFeedback(for log: DailyLog) -> CoachMessage {
        let adherence = computeAdherence(log: log)
        let protein = log.proteinG
        let calories = log.calories
        let steps = log.steps
        let water = log.waterL

        if adherence >= 85 {
            return CoachMessage(
                headline: "Locked in. 🔒",
                body: "Protein's solid, calories on point, steps done. This is what the cut looks like. Keep this exact energy tomorrow.",
                tone: .positive,
                score: adherence
            )
        } else if adherence >= 65 {
            var gaps: [String] = []
            if protein < 150 { gaps.append("protein is low — fix it tonight") }
            if steps < 10000 { gaps.append("\(10000 - steps) steps still on the table") }
            if water < 4.0 { gaps.append("drink more water, you're under 4L") }
            let gapText = gaps.isEmpty ? "Tighten up the little things." : gaps.joined(separator: "; ").capitalizedSentence + "."
            return CoachMessage(
                headline: "Decent day. Push harder.",
                body: "You're doing the work but leaving margin on the table. \(gapText) Average days produce average results.",
                tone: .neutral,
                score: adherence
            )
        } else if calories == 0 {
            return CoachMessage(
                headline: "No data logged yet.",
                body: "Log your meals, water, and steps. You can't manage what you don't measure. Start now — even an estimate beats nothing.",
                tone: .neutral,
                score: 0
            )
        } else {
            return CoachMessage(
                headline: "Below par. Regroup.",
                body: "This day won't move the needle. \(protein < 100 ? "Protein is critically low — 13 kg to lose, muscle is currency." : "") \(steps < 5000 ? "Under 5k steps is sedentary — that's not the plan." : "") One bad day doesn't ruin a cut. A pattern does. Don't make this a habit.",
                tone: .strict,
                score: adherence
            )
        }
    }

    // MARK: - Progress Metrics
    var currentWeightKg: Double {
        weightHistory.last?.weightKg ?? currentProfile.startWeightKg
    }

    var progressPercent: Double {
        let totalLoss = currentProfile.startWeightKg - currentProfile.goalWeightKg
        let achieved = currentProfile.startWeightKg - currentWeightKg
        return max(0, min(achieved / totalLoss, 1.0))
    }

    var projectedEndWeight: Double {
        let weeksElapsed = max(1, Double(Calendar.current.dateComponents([.day], from: currentProfile.createdAt, to: Date()).day ?? 1) / 7.0)
        let rate = (currentProfile.startWeightKg - currentWeightKg) / weeksElapsed
        let weeksLeft = Double(currentProfile.daysRemaining) / 7.0
        return max(currentProfile.goalWeightKg, currentWeightKg - (rate * weeksLeft))
    }

    // MARK: - Toast
    func showToast(_ message: String) {
        toastMessage = message
        toastTimer?.invalidate()
        toastTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            Task { @MainActor in
                withAnimation { self?.toastMessage = nil }
            }
        }
    }

    // MARK: - Sample Data
    private func generateSampleData() {
        let log = todayLog
        log.proteinG = 142
        log.carbsG = 158
        log.fatG = 41
        log.calories = 1762
        log.steps = 7840
        log.waterL = 3.2
        log.sleepHours = 6.5
        log.cardioMinutes = 0
        log.workoutCompleted = true
        todayLog = log
    }

    static func sampleWeightHistory() -> [WeightEntry] {
        var entries: [WeightEntry] = []
        let weights: [Double] = [98, 97.6, 97.2, 96.8, 96.5, 96.1, 95.8]
        for (i, w) in weights.enumerated() {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            entries.append(WeightEntry(weightKg: w, date: date))
        }
        return entries.reversed()
    }
}

// MARK: - Coach Message
struct CoachMessage {
    enum Tone { case positive, neutral, strict }
    let headline: String
    let body: String
    let tone: Tone
    let score: Int

    var toneColor: Color {
        switch tone {
        case .positive: return .ccGreen
        case .neutral:  return .ccOrange
        case .strict:   return .ccRed
        }
    }
    var toneIcon: String {
        switch tone {
        case .positive: return "checkmark.seal.fill"
        case .neutral:  return "exclamationmark.triangle.fill"
        case .strict:   return "xmark.octagon.fill"
        }
    }
}

extension String {
    var capitalizedSentence: String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased() + dropFirst()
    }
}
