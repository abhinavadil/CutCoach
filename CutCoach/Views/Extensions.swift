import SwiftUI

// MARK: - Updated Main Tab with Coach accessible from Dashboard
// The main 5 tabs are: Home, Macros, [+CheckIn], Plan, Progress
// Coach, Habits, Settings accessible via swipe or links from Dashboard

extension DashboardView {
    // This extension adds settings navigation
    var settingsButton: some View {
        NavigationLink {
            SettingsView()
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.ccTextSecondary)
        }
    }
}

// MARK: - Coach Sheet (accessible from dashboard coach card)
struct CoachSheetWrapper: View {
    var body: some View {
        NavigationStack {
            CoachView()
                .navigationBarHidden(true)
        }
    }
}

// MARK: - Habits Sheet
struct HabitsSheetWrapper: View {
    var body: some View {
        NavigationStack {
            HabitsView()
                .navigationBarHidden(true)
        }
    }
}
