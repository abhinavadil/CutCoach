import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appVM: AppViewModel
    @State private var showCheckIn = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $appVM.selectedTab) {
                DashboardView()
                    .tag(0)

                MacroTrackerView()
                    .tag(1)

                // Center — check-in placeholder
                Color.clear
                    .tag(2)

                TrainerPlanView()
                    .tag(3)

                ProgressView()
                    .tag(4)
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif

            // Custom Tab Bar
            CCTabBar(selectedTab: $appVM.selectedTab, showCheckIn: $showCheckIn)
        }
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .top) {
            if let msg = appVM.toastMessage {
                CCToast(message: msg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(999)
            }
        }
        .sheet(isPresented: $showCheckIn) {
            CheckInView()
        }
        .animation(.easeInOut, value: appVM.selectedTab)
    }
}

// MARK: - Custom Tab Bar
struct CCTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showCheckIn: Bool

    let tabs: [(icon: String, label: String, tag: Int)] = [
        ("house.fill",            "Home",     0),
        ("fork.knife",            "Macros",   1),
        ("",                      "",         2), // center button
        ("dumbbell.fill",         "Plan",     3),
        ("chart.line.uptrend.xyaxis", "Progress", 4)
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tag) { tab in
                if tab.tag == 2 {
                    // Center check-in button
                    Button {
                        showCheckIn = true
                        #if os(iOS)
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        #endif
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.ccAccent)
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.ccAccent.opacity(0.5), radius: 12)

                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.ccBackground)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .offset(y: -12)
                } else {
                    Button {
                        selectedTab = tab.tag
                        #if os(iOS)
                        let impact = UISelectionFeedbackGenerator()
                        impact.selectionChanged()
                        #endif
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: selectedTab == tab.tag ? .bold : .regular))
                                .foregroundColor(selectedTab == tab.tag ? .ccAccent : .ccTextTertiary)
                                .scaleEffect(selectedTab == tab.tag ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3), value: selectedTab)

                            Text(tab.label)
                                .font(CCFont.body(10, weight: selectedTab == tab.tag ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab.tag ? .ccAccent : .ccTextTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .padding(.horizontal, CCSpacing.lg)
        .padding(.bottom, 24)
        .background(
            ZStack {
                Color.ccSurface
                LinearGradient(
                    colors: [Color.ccSurface, Color.ccBackground.opacity(0)],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 8)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.ccBorder)
                    .frame(height: 0.5)
            }
        )
    }
}

// MARK: - Toast
struct CCToast: View {
    let message: String

    var body: some View {
        Text(message)
            .font(CCFont.body(14, weight: .medium))
            .foregroundColor(.ccTextPrimary)
            .padding(.horizontal, CCSpacing.lg)
            .padding(.vertical, CCSpacing.md)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(.top, 60)
            .shadow(color: .black.opacity(0.3), radius: 12)
    }
}
