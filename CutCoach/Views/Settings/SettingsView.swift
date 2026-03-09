import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = true
    @State private var notificationsEnabled = true
    @State private var morningReminderTime = Date()
    @State private var eveningReminderTime = Date()
    @State private var showResetAlert = false
    @State private var coachStrictness = 2 // 0=gentle, 1=balanced, 2=strict

    var body: some View {
        ZStack {
            Color.ccBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: CCSpacing.xxl) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(CCFont.display(28, weight: .heavy))
                            .foregroundColor(.ccTextPrimary)
                        Text("Customize your Cut Coach")
                            .font(CCFont.body(14))
                            .foregroundColor(.ccTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 60)
                    .padding(.horizontal, CCSpacing.xl)

                    // Profile card
                    profileCard
                        .padding(.horizontal, CCSpacing.xl)

                    // Notifications
                    settingsSection("NOTIFICATIONS") {
                        AnyView(notificationsSection)
                    }

                    // Targets
                    settingsSection("MACRO TARGETS") {
                        AnyView(macroTargetsSection)
                    }

                    // Coach
                    settingsSection("COACH BEHAVIOUR") {
                        AnyView(coachSection)
                    }

                    // App
                    settingsSection("APP") {
                        AnyView(appSection)
                    }

                    // Danger zone
                    settingsSection("DANGER ZONE") {
                        AnyView(dangerSection)
                    }

                    // Version
                    Text("Cut Coach v1.0.0 · Built for Abhinav")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextTertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.bottom, 120)
            }
        }
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) {
                hasCompletedOnboarding = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will erase all your progress and return to onboarding. This cannot be undone.")
        }
    }

    // MARK: - Profile Card
    var profileCard: some View {
        HStack(spacing: CCSpacing.xl) {
            ZStack {
                Circle()
                    .fill(Color.ccAccentDim)
                    .frame(width: 64, height: 64)
                Text("A")
                    .font(CCFont.display(28, weight: .heavy))
                    .foregroundColor(.ccAccent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Abhinav")
                    .font(CCFont.display(20, weight: .bold))
                    .foregroundColor(.ccTextPrimary)
                Text("6'1\" · 98 kg → 85 kg · 30 days")
                    .font(CCFont.body(13))
                    .foregroundColor(.ccTextSecondary)
                Text("Day 7 of 30")
                    .font(CCFont.body(12))
                    .foregroundColor(.ccAccent)
            }

            Spacer()
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    // MARK: - Notifications
    var notificationsSection: some View {
        VStack(spacing: 0) {
            settingsToggle("Enable Reminders", subtitle: "Morning check-in and evening log", isOn: $notificationsEnabled)
            CCDivider().padding(.horizontal, CCSpacing.lg)
            settingsRow("Morning Weigh-in", trailing: "7:00 AM")
            CCDivider().padding(.horizontal, CCSpacing.lg)
            settingsRow("Evening Log Reminder", trailing: "8:30 PM")
            CCDivider().padding(.horizontal, CCSpacing.lg)
            settingsRow("Workout Reminder", trailing: "5:00 PM")
        }
    }

    // MARK: - Macro Targets
    var macroTargetsSection: some View {
        VStack(spacing: 0) {
            settingsRow("Daily Calories", trailing: "1800–2000 kcal")
            CCDivider().padding(.horizontal, CCSpacing.lg)
            settingsRow("Protein Target", trailing: "160–180 g")
            CCDivider().padding(.horizontal, CCSpacing.lg)
            settingsRow("Carbs Target", trailing: "150–190 g")
            CCDivider().padding(.horizontal, CCSpacing.lg)
            settingsRow("Fat Target", trailing: "40–55 g")
            CCDivider().padding(.horizontal, CCSpacing.lg)
            settingsRow("Daily Steps", trailing: "10,000 min")
            CCDivider().padding(.horizontal, CCSpacing.lg)
            settingsRow("Water Target", trailing: "4–5 L")
        }
    }

    // MARK: - Coach Section
    var coachSection: some View {
        VStack(spacing: CCSpacing.lg) {
            VStack(alignment: .leading, spacing: CCSpacing.md) {
                Text("Coach Tone")
                    .font(CCFont.body(15, weight: .medium))
                    .foregroundColor(.ccTextPrimary)
                    .padding(.horizontal, CCSpacing.lg)
                    .padding(.top, CCSpacing.lg)

                HStack(spacing: 0) {
                    ForEach(Array(["Gentle", "Balanced", "Strict"].enumerated()), id: \.offset) { i, label in
                        Button {
                            withAnimation(.spring(response: 0.3)) { coachStrictness = i }
                        } label: {
                            Text(label)
                                .font(CCFont.body(13, weight: coachStrictness == i ? .semibold : .regular))
                                .foregroundColor(coachStrictness == i ? .ccBackground : .ccTextSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(coachStrictness == i ? Color.ccAccent : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(Color.ccCardElevated)
                .clipShape(RoundedRectangle(cornerRadius: CCRadius.sm))
                .padding(.horizontal, CCSpacing.lg)
                .padding(.bottom, CCSpacing.lg)
            }

            CCDivider().padding(.horizontal, CCSpacing.lg)
            settingsToggle("Daily Verdict", subtitle: "Show AI feedback on dashboard", isOn: .constant(true))
        }
    }

    // MARK: - App Section
    var appSection: some View {
        VStack(spacing: 0) {
            settingsRow("Apple Health Sync", trailing: "Coming Soon")
            CCDivider().padding(.horizontal, CCSpacing.lg)
            settingsRow("Export Data", trailing: "CSV")
            CCDivider().padding(.horizontal, CCSpacing.lg)
            settingsRow("Privacy Policy", trailing: "View")
        }
    }

    // MARK: - Danger Section
    var dangerSection: some View {
        Button {
            showResetAlert = true
        } label: {
            HStack {
                Image(systemName: "trash.fill")
                    .foregroundColor(.ccRed)
                Text("Reset All Data")
                    .font(CCFont.body(15, weight: .medium))
                    .foregroundColor(.ccRed)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.ccTextTertiary)
            }
            .padding(CCSpacing.lg)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helper Views
    func settingsSection<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: CCSpacing.md) {
            Text(title)
                .font(CCFont.body(11, weight: .semibold))
                .foregroundColor(.ccTextTertiary)
                .tracking(1.2)
                .padding(.horizontal, CCSpacing.xl)

            content()
                .background(Color.ccCard)
                .clipShape(RoundedRectangle(cornerRadius: CCRadius.lg))
                .overlay(RoundedRectangle(cornerRadius: CCRadius.lg).stroke(Color.ccBorder, lineWidth: 0.5))
                .padding(.horizontal, CCSpacing.xl)
        }
    }

    func settingsRow(_ label: String, trailing: String) -> some View {
        HStack {
            Text(label)
                .font(CCFont.body(15))
                .foregroundColor(.ccTextPrimary)
            Spacer()
            Text(trailing)
                .font(CCFont.body(14))
                .foregroundColor(.ccTextSecondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.ccTextTertiary)
        }
        .padding(.horizontal, CCSpacing.lg)
        .padding(.vertical, 14)
    }

    func settingsToggle(_ label: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(CCFont.body(15))
                    .foregroundColor(.ccTextPrimary)
                Text(subtitle)
                    .font(CCFont.body(12))
                    .foregroundColor(.ccTextSecondary)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .tint(.ccAccent)
        }
        .padding(.horizontal, CCSpacing.lg)
        .padding(.vertical, CCSpacing.md)
    }
}
