import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @State private var currentStep = 0
    @State private var name = "Abhinav"
    @State private var startWeight = "98"
    @State private var goalWeight = "85"
    @State private var animateIn = false

    let totalSteps = 4

    var body: some View {
        ZStack {
            Color.ccBackground.ignoresSafeArea()

            // Background glow
            RadialGradient(
                colors: [Color.ccAccent.opacity(0.06), Color.clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 600
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i <= currentStep ? Color.ccAccent : Color.ccBorder)
                            .frame(width: i == currentStep ? 28 : 8, height: 4)
                            .animation(.spring(response: 0.4), value: currentStep)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                // Step content
                Group {
                    switch currentStep {
                    case 0: stepWelcome
                    case 1: stepProfile
                    case 2: stepGoals
                    case 3: stepPlan
                    default: stepWelcome
                    }
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: animateIn)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentStep)

                Spacer()

                // Navigation
                VStack(spacing: CCSpacing.md) {
                    CCPrimaryButton(
                        currentStep < totalSteps - 1 ? "Continue" : "Start My Cut",
                        icon: currentStep < totalSteps - 1 ? "arrow.right" : "flame.fill"
                    ) {
                        advance()
                    }

                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation(.spring(response: 0.4)) {
                                currentStep -= 1
                            }
                        }
                        .font(CCFont.body(15))
                        .foregroundColor(.ccTextTertiary)
                    }
                }
                .padding(.horizontal, CCSpacing.xl)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.2)) {
                animateIn = true
            }
        }
    }

    // MARK: - Step: Welcome
    var stepWelcome: some View {
        VStack(alignment: .leading, spacing: CCSpacing.xl) {
            // Logo
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.ccAccent)
                        .frame(width: 56, height: 56)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.ccBackground)
                }
                .ccGlow()

                VStack(alignment: .leading, spacing: 2) {
                    Text("Cut Coach")
                        .font(CCFont.display(26, weight: .heavy))
                        .foregroundColor(.ccTextPrimary)
                    Text("Your transformation starts now")
                        .font(CCFont.body(13))
                        .foregroundColor(.ccTextSecondary)
                }
            }
            .padding(.horizontal, CCSpacing.xl)

            VStack(alignment: .leading, spacing: CCSpacing.lg) {
                Text("No shortcuts.\nNo excuses.\nJust results.")
                    .font(CCFont.display(36, weight: .heavy))
                    .foregroundColor(.ccTextPrimary)
                    .lineSpacing(4)
            }
            .padding(.horizontal, CCSpacing.xl)

            // Feature pills
            VStack(alignment: .leading, spacing: CCSpacing.md) {
                ForEach([
                    ("flame.fill", "Daily macro & calorie tracking"),
                    ("chart.line.uptrend.xyaxis", "Weight & progress analytics"),
                    ("dumbbell.fill", "Custom 5-day trainer plan"),
                    ("brain.head.profile", "AI-style coach feedback"),
                ], id: \.1) { icon, text in
                    HStack(spacing: CCSpacing.md) {
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.ccAccent)
                            .frame(width: 32, height: 32)
                            .background(Color.ccAccentDim)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text(text)
                            .font(CCFont.body(15))
                            .foregroundColor(.ccTextSecondary)
                    }
                }
            }
            .padding(.horizontal, CCSpacing.xl)
        }
    }

    // MARK: - Step: Profile
    var stepProfile: some View {
        VStack(alignment: .leading, spacing: CCSpacing.xxl) {
            VStack(alignment: .leading, spacing: CCSpacing.sm) {
                Text("Who's getting\nshredded?")
                    .font(CCFont.display(34, weight: .heavy))
                    .foregroundColor(.ccTextPrimary)
                    .lineSpacing(4)
                Text("We'll personalize everything for you.")
                    .font(CCFont.body(15))
                    .foregroundColor(.ccTextSecondary)
            }
            .padding(.horizontal, CCSpacing.xl)

            VStack(spacing: CCSpacing.md) {
                CCTextField(label: "Your Name", placeholder: "Abhinav", text: $name, icon: "person.fill")

                HStack(spacing: CCSpacing.md) {
                    CCInfoTile(label: "Height", value: "6'1\"", icon: "ruler.fill")
                    CCInfoTile(label: "Gender", value: "Male", icon: "person.fill")
                }
            }
            .padding(.horizontal, CCSpacing.xl)

            VStack(alignment: .leading, spacing: CCSpacing.md) {
                Text("TRAINING METRICS")
                    .font(CCFont.body(11, weight: .semibold))
                    .foregroundColor(.ccTextTertiary)
                    .tracking(1.2)
                    .padding(.horizontal, CCSpacing.xl)

                HStack(spacing: CCSpacing.md) {
                    CCInfoTile(label: "Experience", value: "Intermediate", icon: "star.fill")
                    CCInfoTile(label: "Gym Access", value: "Full Gym", icon: "dumbbell.fill")
                }
                .padding(.horizontal, CCSpacing.xl)
            }
        }
    }

    // MARK: - Step: Goals
    var stepGoals: some View {
        VStack(alignment: .leading, spacing: CCSpacing.xxl) {
            VStack(alignment: .leading, spacing: CCSpacing.sm) {
                Text("The mission.")
                    .font(CCFont.display(34, weight: .heavy))
                    .foregroundColor(.ccTextPrimary)
                Text("13kg in 30 days. Aggressive but achievable.")
                    .font(CCFont.body(15))
                    .foregroundColor(.ccTextSecondary)
            }
            .padding(.horizontal, CCSpacing.xl)

            VStack(spacing: CCSpacing.md) {
                HStack(spacing: CCSpacing.md) {
                    CCNumberField(label: "Start Weight (kg)", value: $startWeight, icon: "scalemass.fill")
                    CCNumberField(label: "Goal Weight (kg)", value: $goalWeight, icon: "target")
                }

                // Goal card
                VStack(spacing: CCSpacing.lg) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("To Lose")
                                .font(CCFont.body(12))
                                .foregroundColor(.ccTextSecondary)
                            Text("\(Int((Double(startWeight) ?? 98) - (Double(goalWeight) ?? 85))) kg")
                                .font(CCFont.mono(28, weight: .bold))
                                .foregroundColor(.ccAccent)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Timeline")
                                .font(CCFont.body(12))
                                .foregroundColor(.ccTextSecondary)
                            Text("30 days")
                                .font(CCFont.mono(28, weight: .bold))
                                .foregroundColor(.ccTextPrimary)
                        }
                    }

                    CCDivider()

                    HStack {
                        metricPill("~0.43 kg", "per day")
                        Spacer()
                        metricPill("~3 kg", "per week")
                        Spacer()
                        metricPill("~3500", "deficit/day")
                    }
                }
                .padding(CCSpacing.xl)
                .ccCard()
            }
            .padding(.horizontal, CCSpacing.xl)

            Text("⚡️ This is aggressive. Perfect execution required. No excuses.")
                .font(CCFont.body(13, weight: .medium))
                .foregroundColor(.ccOrange)
                .padding(.horizontal, CCSpacing.xl)
        }
    }

    // MARK: - Step: Plan Preview
    var stepPlan: some View {
        VStack(alignment: .leading, spacing: CCSpacing.xxl) {
            VStack(alignment: .leading, spacing: CCSpacing.sm) {
                Text("Your plan is\nloaded in.")
                    .font(CCFont.display(34, weight: .heavy))
                    .foregroundColor(.ccTextPrimary)
                    .lineSpacing(4)
                Text("Trainer-designed. Coach-enforced. Let's go.")
                    .font(CCFont.body(15))
                    .foregroundColor(.ccTextSecondary)
            }
            .padding(.horizontal, CCSpacing.xl)

            VStack(spacing: CCSpacing.md) {
                planPillRow(icon: "fork.knife", title: "Nutrition", detail: "1800–2000 kcal · 170g protein")
                planPillRow(icon: "dumbbell.fill", title: "Training", detail: "5-day split + abs 2x/week")
                planPillRow(icon: "figure.run", title: "Cardio", detail: "Daily requirement")
                planPillRow(icon: "drop.fill", title: "Hydration", detail: "4–5 L water daily")
                planPillRow(icon: "figure.walk", title: "Steps", detail: "10,000 minimum — no exceptions")
                planPillRow(icon: "flask.fill", title: "Supplements", detail: "Creatine 5g/day (post-workout)")
            }
            .padding(.horizontal, CCSpacing.xl)
        }
    }

    private func metricPill(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(CCFont.mono(15, weight: .bold))
                .foregroundColor(.ccTextPrimary)
            Text(label)
                .font(CCFont.body(11))
                .foregroundColor(.ccTextTertiary)
        }
    }

    private func planPillRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: CCSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.ccAccent)
                .frame(width: 36, height: 36)
                .background(Color.ccAccentDim)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CCFont.body(14, weight: .semibold))
                    .foregroundColor(.ccTextPrimary)
                Text(detail)
                    .font(CCFont.body(12))
                    .foregroundColor(.ccTextSecondary)
            }

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.ccGreen)
        }
        .padding(CCSpacing.lg)
        .ccCard()
    }

    private func advance() {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        #endif

        if currentStep < totalSteps - 1 {
            withAnimation(.spring(response: 0.4)) {
                animateIn = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                currentStep += 1
                withAnimation(.spring(response: 0.5)) {
                    animateIn = true
                }
            }
        } else {
            withAnimation(.easeInOut(duration: 0.4)) {
                hasCompletedOnboarding = true
            }
        }
    }
}

// MARK: - Supporting Input Components
struct CCTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: CCSpacing.sm) {
            Text(label.uppercased())
                .font(CCFont.body(11, weight: .semibold))
                .foregroundColor(.ccTextTertiary)
                .tracking(1)

            HStack(spacing: CCSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.ccAccent)
                    .frame(width: 20)

                TextField(placeholder, text: $text)
                    .font(CCFont.body(16))
                    .foregroundColor(.ccTextPrimary)
                    .tint(.ccAccent)
            }
            .padding(CCSpacing.lg)
            .ccCard()
        }
    }
}

struct CCNumberField: View {
    let label: String
    @Binding var value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: CCSpacing.sm) {
            Text(label.uppercased())
                .font(CCFont.body(10, weight: .semibold))
                .foregroundColor(.ccTextTertiary)
                .tracking(1)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: CCSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(.ccAccent)

                TextField("0", text: $value)
                    .font(CCFont.mono(18, weight: .bold))
                    .foregroundColor(.ccTextPrimary)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                    .tint(.ccAccent)
            }
            .padding(CCSpacing.lg)
            .ccCard()
        }
    }
}

struct CCInfoTile: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: CCSpacing.sm) {
            HStack(spacing: CCSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.ccAccent)
                Text(label)
                    .font(CCFont.body(11))
                    .foregroundColor(.ccTextSecondary)
            }
            Text(value)
                .font(CCFont.display(16, weight: .bold))
                .foregroundColor(.ccTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CCSpacing.lg)
        .ccCard()
    }
}
