import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var appVM: AppViewModel
    @State private var selectedRange = 7 // days

    var body: some View {
        ZStack {
            Color.ccBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: CCSpacing.xxl) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Progress")
                            .font(CCFont.display(28, weight: .heavy))
                            .foregroundColor(.ccTextPrimary)
                        Text("Your transformation, tracked.")
                            .font(CCFont.body(14))
                            .foregroundColor(.ccTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 60)
                    .padding(.horizontal, CCSpacing.xl)

                    // Goal progress card
                    goalProgressCard
                        .padding(.horizontal, CCSpacing.xl)

                    // Stats grid
                    statsGrid
                        .padding(.horizontal, CCSpacing.xl)

                    // Weight chart
                    weightChartSection
                        .padding(.horizontal, CCSpacing.xl)

                    // Adherence heatmap
                    adherenceSection
                        .padding(.horizontal, CCSpacing.xl)

                    // Macro averages
                    macroAveragesSection
                        .padding(.horizontal, CCSpacing.xl)

                    // Projections
                    projectionCard
                        .padding(.horizontal, CCSpacing.xl)
                }
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - Goal Progress
    var goalProgressCard: some View {
        VStack(spacing: CCSpacing.xl) {
            HStack {
                Text("CUT MISSION")
                    .font(CCFont.body(11, weight: .semibold))
                    .foregroundColor(.ccTextTertiary)
                    .tracking(1.2)
                Spacer()
                CCBadge(text: "\(appVM.currentProfile.daysRemaining) DAYS LEFT")
            }

            // Timeline bar
            VStack(spacing: CCSpacing.lg) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Start")
                            .font(CCFont.body(11))
                            .foregroundColor(.ccTextTertiary)
                        Text("\(Int(appVM.currentProfile.startWeightKg)) kg")
                            .font(CCFont.mono(18, weight: .bold))
                            .foregroundColor(.ccTextSecondary)
                    }
                    Spacer()
                    VStack(alignment: .center, spacing: 3) {
                        Text("Now")
                            .font(CCFont.body(11))
                            .foregroundColor(.ccTextSecondary)
                        Text(String(format: "%.1f kg", appVM.currentWeightKg))
                            .font(CCFont.mono(22, weight: .heavy))
                            .foregroundColor(.ccAccent)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Goal")
                            .font(CCFont.body(11))
                            .foregroundColor(.ccTextTertiary)
                        Text("\(Int(appVM.currentProfile.goalWeightKg)) kg")
                            .font(CCFont.mono(18, weight: .bold))
                            .foregroundColor(.ccGreen)
                    }
                }

                // Progress bar with current marker
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Track
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.ccBorder)
                            .frame(height: 12)

                        // Filled
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color.ccAccent, Color.ccGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(appVM.progressPercent), height: 12)
                            .animation(.spring(response: 1.0, dampingFraction: 0.8), value: appVM.progressPercent)

                        // Marker
                        Circle()
                            .fill(Color.ccBackground)
                            .frame(width: 18, height: 18)
                            .overlay(Circle().stroke(Color.ccAccent, lineWidth: 3))
                            .offset(x: geo.size.width * CGFloat(appVM.progressPercent) - 9)
                            .animation(.spring(response: 1.0, dampingFraction: 0.8), value: appVM.progressPercent)
                    }
                }
                .frame(height: 18)

                Text(String(format: "%.1f%% complete · %.1f kg to go", appVM.progressPercent * 100, appVM.currentWeightKg - appVM.currentProfile.goalWeightKg))
                    .font(CCFont.body(13))
                    .foregroundColor(.ccTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    // MARK: - Stats Grid
    var statsGrid: some View {
        VStack(spacing: CCSpacing.md) {
            CCSectionHeader(title: "This Week")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CCSpacing.md) {
                statCard("Lost This Week", value: "2.2 kg", icon: "arrow.down.circle.fill", color: .ccGreen, delta: nil)
                statCard("Avg Adherence", value: "74%", icon: "checkmark.seal.fill", color: .ccAccent, delta: "+8%")
                statCard("Avg Protein", value: "148g", icon: "chart.bar.fill", color: .ccBlue, delta: nil)
                statCard("Total Steps", value: "71.4k", icon: "figure.walk", color: .ccOrange, delta: nil)
                statCard("Workouts", value: "4 / 5", icon: "dumbbell.fill", color: .ccPurple, delta: nil)
                statCard("Avg Sleep", value: "6.4h", icon: "moon.zzz.fill", color: Color(hex: "818CF8"), delta: "-0.3h")
            }
        }
    }

    func statCard(_ label: String, value: String, icon: String, color: Color, delta: String?) -> some View {
        VStack(alignment: .leading, spacing: CCSpacing.lg) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Spacer()

                if let delta = delta {
                    Text(delta)
                        .font(CCFont.mono(11, weight: .bold))
                        .foregroundColor(delta.hasPrefix("+") ? .ccGreen : .ccRed)
                }
            }

            Text(value)
                .font(CCFont.mono(22, weight: .heavy))
                .foregroundColor(.ccTextPrimary)

            Text(label)
                .font(CCFont.body(12))
                .foregroundColor(.ccTextSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .padding(CCSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ccCard()
    }

    // MARK: - Weight Chart
    var weightChartSection: some View {
        VStack(spacing: CCSpacing.md) {
            HStack {
                CCSectionHeader(title: "Weight Trend")
                Spacer()
                HStack(spacing: CCSpacing.sm) {
                    ForEach([7, 14, 30], id: \.self) { days in
                        Button {
                            withAnimation(.spring(response: 0.3)) { selectedRange = days }
                        } label: {
                            Text("\(days)d")
                                .font(CCFont.body(12, weight: selectedRange == days ? .semibold : .regular))
                                .foregroundColor(selectedRange == days ? .ccBackground : .ccTextTertiary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(selectedRange == days ? Color.ccAccent : Color.clear)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Custom chart
            weightLineChart
                .frame(height: 180)
                .ccCard()
        }
    }

    var weightLineChart: some View {
        let weights = appVM.weightHistory.suffix(selectedRange)
        let minW = (weights.map { $0.weightKg }.min() ?? 85) - 1
        let maxW = (weights.map { $0.weightKg }.max() ?? 98) + 1
        let range = maxW - minW

        return GeometryReader { geo in
            ZStack {
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<4) { i in
                        Spacer()
                        if i < 3 { Rectangle().fill(Color.ccBorder.opacity(0.5)).frame(height: 0.5) }
                    }
                }
                .padding(.horizontal, CCSpacing.xl)
                .padding(.vertical, 40)

                // Goal line
                let goalY = geo.size.height - 40 - (CGFloat(appVM.currentProfile.goalWeightKg - minW) / CGFloat(range)) * (geo.size.height - 80)
                Path { path in
                    path.move(to: CGPoint(x: CCSpacing.xl, y: goalY))
                    path.addLine(to: CGPoint(x: geo.size.width - CCSpacing.xl, y: goalY))
                }
                .stroke(Color.ccGreen.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))

                Text("Goal \(Int(appVM.currentProfile.goalWeightKg))kg")
                    .font(CCFont.mono(10, weight: .bold))
                    .foregroundColor(.ccGreen.opacity(0.7))
                    .position(x: geo.size.width - 50, y: goalY - 10)

                // Weight line
                if weights.count > 1 {
                    let points: [CGPoint] = weights.enumerated().map { i, entry in
                        let x = CCSpacing.xl + CGFloat(i) / CGFloat(weights.count - 1) * (geo.size.width - CCSpacing.xl * 2)
                        let y = geo.size.height - 40 - (CGFloat(entry.weightKg - minW) / CGFloat(range)) * (geo.size.height - 80)
                        return CGPoint(x: x, y: y)
                    }

                    // Fill
                    Path { path in
                        path.move(to: CGPoint(x: points[0].x, y: geo.size.height - 40))
                        path.addLine(to: points[0])
                        for i in 1..<points.count {
                            let cp1 = CGPoint(x: (points[i-1].x + points[i].x) / 2, y: points[i-1].y)
                            let cp2 = CGPoint(x: (points[i-1].x + points[i].x) / 2, y: points[i].y)
                            path.addCurve(to: points[i], control1: cp1, control2: cp2)
                        }
                        path.addLine(to: CGPoint(x: points.last!.x, y: geo.size.height - 40))
                    }
                    .fill(LinearGradient(colors: [Color.ccAccent.opacity(0.25), Color.clear], startPoint: .top, endPoint: .bottom))

                    // Line
                    Path { path in
                        path.move(to: points[0])
                        for i in 1..<points.count {
                            let cp1 = CGPoint(x: (points[i-1].x + points[i].x) / 2, y: points[i-1].y)
                            let cp2 = CGPoint(x: (points[i-1].x + points[i].x) / 2, y: points[i].y)
                            path.addCurve(to: points[i], control1: cp1, control2: cp2)
                        }
                    }
                    .stroke(Color.ccAccent, style: StrokeStyle(lineWidth: 2, lineCap: .round))

                    // Dots
                    ForEach(Array(points.enumerated()), id: \.offset) { i, pt in
                        Circle()
                            .fill(Color.ccAccent)
                            .frame(width: i == points.count - 1 ? 10 : 5, height: i == points.count - 1 ? 10 : 5)
                            .position(pt)
                    }

                    // Latest label
                    if let last = points.last, let lastWeight = weights.last {
                        Text(String(format: "%.1f", lastWeight.weightKg))
                            .font(CCFont.mono(12, weight: .bold))
                            .foregroundColor(.ccAccent)
                            .position(x: last.x, y: last.y - 18)
                    }
                }
            }
        }
        .padding(CCSpacing.lg)
    }

    // MARK: - Adherence Heatmap
    var adherenceSection: some View {
        VStack(spacing: CCSpacing.md) {
            CCSectionHeader(title: "Adherence Heatmap", subtitle: "Last 30 days")

            let scores = adherenceSampleData()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(Array(scores.enumerated()), id: \.offset) { i, score in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(heatmapColor(score: score))
                        .frame(height: 28)
                        .overlay(
                            Text(score > 0 ? "\(score)" : "")
                                .font(CCFont.mono(8, weight: .bold))
                                .foregroundColor(.ccBackground.opacity(0.7))
                        )
                }
            }

            // Legend
            HStack(spacing: CCSpacing.md) {
                Text("Less")
                    .font(CCFont.body(11))
                    .foregroundColor(.ccTextTertiary)
                ForEach([0, 40, 60, 80, 100], id: \.self) { v in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(heatmapColor(score: v))
                        .frame(width: 16, height: 16)
                }
                Text("More")
                    .font(CCFont.body(11))
                    .foregroundColor(.ccTextTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }

    func heatmapColor(score: Int) -> Color {
        if score == 0 { return Color.ccBorder }
        if score < 50 { return Color.ccRed.opacity(0.5) }
        if score < 70 { return Color.ccOrange.opacity(0.6) }
        if score < 85 { return Color.ccAccent.opacity(0.5) }
        return Color.ccAccent
    }

    func adherenceSampleData() -> [Int] {
        [0, 0, 45, 78, 85, 92, 60, 70, 88, 95, 72, 80, 65, 90, 85, 78, 72, 88, 95, 100, 82, 74, 90, 88, 76, 85, 92, 78, 84, 88]
    }

    // MARK: - Macro Averages
    var macroAveragesSection: some View {
        VStack(spacing: CCSpacing.md) {
            CCSectionHeader(title: "7-Day Macro Averages")

            VStack(spacing: CCSpacing.md) {
                macroAverageRow("Calories", avg: 1821, target: 1900, color: .ccAccent, unit: "kcal")
                macroAverageRow("Protein",  avg: 152,  target: 170,  color: .ccBlue,   unit: "g")
                macroAverageRow("Carbs",    avg: 168,  target: 170,  color: .ccOrange,  unit: "g")
                macroAverageRow("Fat",      avg: 44,   target: 48,   color: .ccPurple,  unit: "g")
            }
            .padding(CCSpacing.xl)
            .ccCard()
        }
    }

    func macroAverageRow(_ name: String, avg: Int, target: Int, color: Color, unit: String) -> some View {
        VStack(spacing: CCSpacing.sm) {
            HStack {
                Text(name)
                    .font(CCFont.body(14, weight: .medium))
                    .foregroundColor(.ccTextSecondary)
                Spacer()
                HStack(spacing: 4) {
                    Text("\(avg)")
                        .font(CCFont.mono(15, weight: .bold))
                        .foregroundColor(color)
                    Text("/ \(target)\(unit)")
                        .font(CCFont.mono(12))
                        .foregroundColor(.ccTextTertiary)
                }
            }
            CCProgressBar(value: min(Double(avg) / Double(target), 1.0), color: color, height: 5)
        }
    }

    // MARK: - Projection
    var projectionCard: some View {
        VStack(alignment: .leading, spacing: CCSpacing.lg) {
            HStack {
                Text("PROJECTION")
                    .font(CCFont.body(11, weight: .semibold))
                    .foregroundColor(.ccTextTertiary)
                    .tracking(1.2)
                Spacer()
                CCBadge(text: "AI ESTIMATE", color: .ccPurple)
            }

            HStack(spacing: CCSpacing.xl) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("At current pace")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextSecondary)
                    Text(String(format: "%.1f kg", appVM.projectedEndWeight))
                        .font(CCFont.mono(28, weight: .heavy))
                        .foregroundColor(appVM.projectedEndWeight <= appVM.currentProfile.goalWeightKg ? .ccGreen : .ccOrange)
                    Text("by goal date")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Need to lose")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextSecondary)
                    Text(String(format: "%.2f kg/day", (appVM.currentWeightKg - appVM.currentProfile.goalWeightKg) / Double(max(1, appVM.currentProfile.daysRemaining))))
                        .font(CCFont.mono(18, weight: .bold))
                        .foregroundColor(.ccAccent)
                    Text("to hit goal")
                        .font(CCFont.body(12))
                        .foregroundColor(.ccTextTertiary)
                }
            }

            let onTrack = appVM.projectedEndWeight <= appVM.currentProfile.goalWeightKg
            HStack(spacing: CCSpacing.sm) {
                Image(systemName: onTrack ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(onTrack ? .ccGreen : .ccOrange)
                Text(onTrack
                     ? "You're on track. Maintain this pace."
                     : "Slightly behind. Push cardio and watch snacking.")
                    .font(CCFont.body(13))
                    .foregroundColor(.ccTextSecondary)
            }
            .padding(CCSpacing.md)
            .background((onTrack ? Color.ccGreen : Color.ccOrange).opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CCRadius.sm))
        }
        .padding(CCSpacing.xl)
        .ccCard()
    }
}
