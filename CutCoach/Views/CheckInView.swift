import SwiftUI

struct CheckInView: View {
    @EnvironmentObject var appVM: AppViewModel
    @Environment(\.dismiss) var dismiss

    @State private var weightInput = ""
    @State private var waterInput = ""
    @State private var stepsInput = ""
    @State private var sleepInput = ""
    @State private var cardioMinInput = ""
    @State private var workoutDone = false
    @State private var absDone = false
    @State private var moodScore = 3
    @State private var energyScore = 3
    @State private var hungerScore = 3
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ccBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: CCSpacing.xxl) {
                        // Date header
                        dateHeader

                        // Weight
                        sectionCard(title: "MORNING WEIGH-IN", icon: "scalemass.fill") {
                            AnyView(weightSection)
                        }

                        // Activity numbers
                        sectionCard(title: "ACTIVITY", icon: "figure.walk") {
                            AnyView(activitySection)
                        }

                        // Workout checkboxes
                        sectionCard(title: "SESSION", icon: "dumbbell.fill") {
                            AnyView(sessionSection)
                        }

                        // Biofeedback
                        sectionCard(title: "HOW ARE YOU FEELING?", icon: "brain.head.profile") {
                            AnyView(biofeedbackSection)
                        }

                        // Submit
                        CCPrimaryButton("Save Check-In", icon: "checkmark.seal.fill") {
                            saveCheckIn()
                        }
                        .padding(.horizontal, CCSpacing.xl)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, CCSpacing.xl)
                }

                // Success overlay
                if showSuccess {
                    successOverlay
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Daily Check-In")
                        .font(CCFont.display(16, weight: .bold))
                        .foregroundColor(.ccTextPrimary)
                }
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(CCFont.body(15))
                        .foregroundColor(.ccAccent)
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                        .font(CCFont.body(15))
                        .foregroundColor(.ccAccent)
                }
                #endif
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Date Header
    var dateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().formatted(date: .complete, time: .omitted))
                    .font(CCFont.body(13))
                    .foregroundColor(.ccTextSecondary)
                Text("How was your day, Abhinav?")
                    .font(CCFont.display(20, weight: .bold))
                    .foregroundColor(.ccTextPrimary)
            }
            Spacer()
            CCBadge(text: "Day \(dayNumber)")
        }
        .padding(.horizontal, CCSpacing.xl)
    }

    // MARK: - Weight Section
    var weightSection: some View {
        VStack(alignment: .leading, spacing: CCSpacing.lg) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                TextField("0.0", text: $weightInput)
                    .font(CCFont.mono(48, weight: .heavy))
                    .foregroundColor(.ccAccent)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .tint(.ccAccent)
                    .frame(maxWidth: 160)

                Text("kg")
                    .font(CCFont.mono(20))
                    .foregroundColor(.ccTextSecondary)
            }

            if let w = Double(weightInput), w > 0 {
                let delta = w - appVM.currentWeightKg
                HStack(spacing: CCSpacing.sm) {
                    Image(systemName: delta <= 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .foregroundColor(delta <= 0 ? .ccGreen : .ccRed)
                    Text(String(format: "%+.1f kg from yesterday", delta))
                        .font(CCFont.body(13, weight: .medium))
                        .foregroundColor(delta <= 0 ? .ccGreen : .ccRed)
                }
            }
        }
    }

    // MARK: - Activity Section
    var activitySection: some View {
        VStack(spacing: CCSpacing.md) {
            HStack(spacing: CCSpacing.md) {
                numberInputField("Steps", placeholder: "0", value: $stepsInput, icon: "figure.walk", color: .ccGreen, unit: "steps")
                numberInputField("Water", placeholder: "0.0", value: $waterInput, icon: "drop.fill", color: .ccBlue, unit: "litres")
            }
            HStack(spacing: CCSpacing.md) {
                numberInputField("Sleep", placeholder: "0.0", value: $sleepInput, icon: "moon.fill", color: .ccPurple, unit: "hours")
                numberInputField("Cardio", placeholder: "0", value: $cardioMinInput, icon: "figure.run", color: .ccOrange, unit: "minutes")
            }
        }
    }

    // MARK: - Session Section
    var sessionSection: some View {
        VStack(spacing: CCSpacing.md) {
            checkboxRow(
                title: "Gym Workout Completed",
                subtitle: weekdayPlan,
                isOn: $workoutDone,
                color: .ccAccent
            )
            CCDivider()
            checkboxRow(
                title: "Abs Session Done",
                subtitle: "Plank · Crunches · Leg Raises",
                isOn: $absDone,
                color: .ccGreen
            )
        }
    }

    // MARK: - Biofeedback
    var biofeedbackSection: some View {
        VStack(spacing: CCSpacing.lg) {
            biofeedbackRow("Mood", score: $moodScore, emojis: ["😞", "😕", "😐", "🙂", "😄"])
            CCDivider()
            biofeedbackRow("Energy", score: $energyScore, emojis: ["💀", "😴", "😑", "⚡️", "🔥"])
            CCDivider()
            biofeedbackRow("Hunger", score: $hungerScore, emojis: ["🍽️", "😤", "😊", "😌", "😁"])
        }
    }

    // MARK: - Success Overlay
    var successOverlay: some View {
        ZStack {
            Color.ccBackground.opacity(0.95).ignoresSafeArea()
            VStack(spacing: CCSpacing.xl) {
                ZStack {
                    Circle()
                        .fill(Color.ccAccentDim)
                        .frame(width: 100, height: 100)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.ccAccent)
                }
                .ccGlow()
                .scaleEffect(showSuccess ? 1 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccess)

                Text("Check-In Saved")
                    .font(CCFont.display(28, weight: .heavy))
                    .foregroundColor(.ccTextPrimary)

                Text("Coach will review your data.\nKeep the consistency going.")
                    .font(CCFont.body(15))
                    .foregroundColor(.ccTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                CCPrimaryButton("Close", icon: nil) { dismiss() }
                    .padding(.horizontal, 60)
            }
        }
        .transition(.opacity)
    }

    // MARK: - Helper Views
    func sectionCard<C: View>(title: String, icon: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: CCSpacing.lg) {
            HStack(spacing: CCSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.ccAccent)
                Text(title)
                    .font(CCFont.body(11, weight: .semibold))
                    .foregroundColor(.ccTextTertiary)
                    .tracking(1.2)
            }
            content()
        }
        .padding(CCSpacing.xl)
        .ccCard()
        .padding(.horizontal, CCSpacing.xl)
    }

    func numberInputField(_ label: String, placeholder: String, value: Binding<String>, icon: String, color: Color, unit: String) -> some View {
        VStack(alignment: .leading, spacing: CCSpacing.sm) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 11)).foregroundColor(color)
                Text(label).font(CCFont.body(11)).foregroundColor(.ccTextSecondary)
            }
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                TextField(placeholder, text: value)
                    .font(CCFont.mono(22, weight: .bold))
                    .foregroundColor(.ccTextPrimary)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .tint(.ccAccent)
                Text(unit)
                    .font(CCFont.body(11))
                    .foregroundColor(.ccTextTertiary)
            }
            CCProgressBar(value: progressFor(label: label, value: Double(value.wrappedValue) ?? 0), color: color, height: 3)
        }
        .padding(CCSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ccCard(elevated: true)
    }

    func checkboxRow(title: String, subtitle: String, isOn: Binding<Bool>, color: Color) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { isOn.wrappedValue.toggle() }
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        } label: {
            HStack(spacing: CCSpacing.lg) {
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(isOn.wrappedValue ? color : .ccTextTertiary)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(CCFont.body(15, weight: .semibold))
                        .foregroundColor(.ccTextPrimary)
                    Text(subtitle)
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextSecondary)
                }
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }

    func biofeedbackRow(_ label: String, score: Binding<Int>, emojis: [String]) -> some View {
        HStack {
            Text(label)
                .font(CCFont.body(14, weight: .medium))
                .foregroundColor(.ccTextSecondary)
                .frame(width: 60, alignment: .leading)

            Spacer()

            HStack(spacing: CCSpacing.lg) {
                ForEach(1...5, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3)) { score.wrappedValue = i }
                        #if os(iOS)
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        #endif
                    } label: {
                        Text(emojis[i - 1])
                            .font(.system(size: score.wrappedValue == i ? 26 : 20))
                            .opacity(score.wrappedValue == i ? 1 : 0.35)
                            .scaleEffect(score.wrappedValue == i ? 1.1 : 1.0)
                    }
                }
            }
        }
    }

    // MARK: - Helpers
    var dayNumber: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date().addingTimeInterval(-30 * 86400)), to: Date()).day ?? 1
    }

    var weekdayPlan: String {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let plans = ["", "Rest", "Chest + Tri", "Back + Bi", "Active Recovery", "Shoulders + Core", "Legs", "Cardio"]
        return plans[min(weekday, plans.count - 1)]
    }

    func progressFor(label: String, value: Double) -> Double {
        switch label {
        case "Steps":  return min(value / 10000, 1.0)
        case "Water":  return min(value / 4.5, 1.0)
        case "Sleep":  return min(value / 7.5, 1.0)
        case "Cardio": return min(value / 30, 1.0)
        default:       return 0
        }
    }

    func saveCheckIn() {
        let log = appVM.todayLog
        if let w = Double(weightInput), w > 0 {
            log.morningWeightKg = w
            appVM.weightHistory.append(WeightEntry(weightKg: w))
        }
        if let steps = Int(stepsInput) { log.steps = steps }
        if let water = Double(waterInput) { log.waterL = water }
        if let sleep = Double(sleepInput) { log.sleepHours = sleep }
        if let cardio = Int(cardioMinInput) { log.cardioMinutes = cardio }
        log.workoutCompleted = workoutDone
        log.absCompleted = absDone
        log.moodScore = moodScore
        log.energyScore = energyScore
        log.hungerScore = hungerScore
        log.adherenceScore = appVM.computeAdherence(log: log)

        #if os(iOS)
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)
        #endif

        withAnimation(.spring(response: 0.5)) { showSuccess = true }
    }
}
