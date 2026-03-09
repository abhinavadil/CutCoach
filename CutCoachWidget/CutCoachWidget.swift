import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Widget Entry
struct CutCoachEntry: TimelineEntry {
    let date: Date
    let calories: Int
    let targetCalories: Int
    let proteinG: Double
    let targetProteinG: Double
    let steps: Int
    let adherenceScore: Int
    let currentWeightKg: Double
    let goalWeightKg: Double
    let daysRemaining: Int
    let coachLine: String
}

// MARK: - Timeline Provider
struct CutCoachProvider: TimelineProvider {
    func placeholder(in context: Context) -> CutCoachEntry {
        sampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (CutCoachEntry) -> Void) {
        completion(sampleEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CutCoachEntry>) -> Void) {
        // In production: fetch from App Group shared container
        let entry = loadCurrentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadCurrentEntry() -> CutCoachEntry {
        // Read from shared UserDefaults (App Group)
        let defaults = UserDefaults(suiteName: "group.com.cutcoach.app") ?? .standard
        return CutCoachEntry(
            date: Date(),
            calories: defaults.integer(forKey: "widget_calories"),
            targetCalories: defaults.integer(forKey: "widget_target_calories"),
            proteinG: defaults.double(forKey: "widget_protein"),
            targetProteinG: defaults.double(forKey: "widget_target_protein"),
            steps: defaults.integer(forKey: "widget_steps"),
            adherenceScore: defaults.integer(forKey: "widget_adherence"),
            currentWeightKg: defaults.double(forKey: "widget_current_weight"),
            goalWeightKg: defaults.double(forKey: "widget_goal_weight"),
            daysRemaining: defaults.integer(forKey: "widget_days_remaining"),
            coachLine: defaults.string(forKey: "widget_coach_line") ?? "Log your meals. Hit your steps. That's the plan."
        )
    }

    private func sampleEntry() -> CutCoachEntry {
        CutCoachEntry(
            date: Date(),
            calories: 1421,
            targetCalories: 1900,
            proteinG: 142,
            targetProteinG: 170,
            steps: 7840,
            adherenceScore: 74,
            currentWeightKg: 95.8,
            goalWeightKg: 85,
            daysRemaining: 23,
            coachLine: "7,840 steps. Push to 10k."
        )
    }
}

// MARK: - Small Widget (2x2)
struct CutCoachSmallWidget: View {
    let entry: CutCoachEntry

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "C8F53C"))
                    Text("CUT")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(hex: "C8F53C"))
                    Spacer()
                    Text("\(entry.daysRemaining)d")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "8888A8"))
                }

                Spacer()

                // Score ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 5)
                    Circle()
                        .trim(from: 0, to: CGFloat(entry.adherenceScore) / 100)
                        .stroke(Color(hex: "C8F53C"), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(entry.adherenceScore)")
                        .font(.system(size: 18, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                }
                .frame(width: 52, height: 52)

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.calories) kcal")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("\(entry.steps.formatted()) steps")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(hex: "8888A8"))
                }
            }
            .padding(14)
        }
    }
}

// MARK: - Medium Widget (4x2)
struct CutCoachMediumWidget: View {
    let entry: CutCoachEntry

    var body: some View {
        ZStack {
            Color(hex: "0A0A0F")

            HStack(spacing: 0) {
                // Left: Score + weight
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "C8F53C"))
                        Text("CUT COACH")
                            .font(.system(size: 11, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(hex: "C8F53C"))
                    }

                    Spacer()

                    Text(String(format: "%.1f kg", entry.currentWeightKg))
                        .font(.system(size: 24, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)

                    Text("\(String(format: "%.1f", entry.currentWeightKg - entry.goalWeightKg)) to goal")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(hex: "C8F53C"))

                    Text(entry.coachLine)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "8888A8"))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)

                // Divider
                Rectangle()
                    .fill(Color(hex: "2A2A38"))
                    .frame(width: 0.5)

                // Right: Macro bars
                VStack(alignment: .leading, spacing: 6) {
                    widgetMacroBar("CAL", value: entry.calories, target: entry.targetCalories, unit: "", color: Color(hex: "C8F53C"))
                    widgetMacroBar("PRO", value: Int(entry.proteinG), target: Int(entry.targetProteinG), unit: "g", color: Color(hex: "60A5FA"))
                    widgetMacroBar("STP", value: entry.steps, target: 10000, unit: "", color: Color(hex: "34D399"))

                    Spacer()

                    Text("\(entry.daysRemaining) days left")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "55556A"))
                }
                .frame(maxWidth: .infinity)
                .padding(14)
            }
        }
    }

    func widgetMacroBar(_ label: String, value: Int, target: Int, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(label)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "8888A8"))
                Spacer()
                Text("\(value)\(unit)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(color.opacity(0.15)).frame(height: 4)
                    RoundedRectangle(cornerRadius: 2).fill(color)
                        .frame(width: min(geo.size.width * CGFloat(value) / CGFloat(target), geo.size.width), height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Widget Bundle
@main
struct CutCoachWidgetBundle: WidgetBundle {
    var body: some Widget {
        CutCoachWidget()
    }
}

struct CutCoachWidget: Widget {
    let kind = "CutCoachWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CutCoachProvider()) { entry in
            CutCoachWidgetView(entry: entry)
                .containerBackground(Color(hex: "0A0A0F"), for: .widget)
        }
        .configurationDisplayName("Cut Coach")
        .description("Track your daily cut metrics at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CutCoachWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: CutCoachEntry

    var body: some View {
        switch family {
        case .systemSmall:  CutCoachSmallWidget(entry: entry)
        case .systemMedium: CutCoachMediumWidget(entry: entry)
        default:            CutCoachSmallWidget(entry: entry)
        }
    }
}

// MARK: - Widget Data Writer (call from main app)
struct WidgetDataWriter {
    static func write(
        calories: Int,
        targetCalories: Int,
        proteinG: Double,
        targetProteinG: Double,
        steps: Int,
        adherenceScore: Int,
        currentWeightKg: Double,
        goalWeightKg: Double,
        daysRemaining: Int,
        coachLine: String
    ) {
        let defaults = UserDefaults(suiteName: "group.com.cutcoach.app") ?? .standard
        defaults.set(calories,          forKey: "widget_calories")
        defaults.set(targetCalories,    forKey: "widget_target_calories")
        defaults.set(proteinG,          forKey: "widget_protein")
        defaults.set(targetProteinG,    forKey: "widget_target_protein")
        defaults.set(steps,             forKey: "widget_steps")
        defaults.set(adherenceScore,    forKey: "widget_adherence")
        defaults.set(currentWeightKg,   forKey: "widget_current_weight")
        defaults.set(goalWeightKg,      forKey: "widget_goal_weight")
        defaults.set(daysRemaining,     forKey: "widget_days_remaining")
        defaults.set(coachLine,         forKey: "widget_coach_line")
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// Color hex extension for widget (no UIKit access)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
