import SwiftUI

struct CoachView: View {
    @EnvironmentObject var appVM: AppViewModel
    @State private var isThinking = false
    @State private var displayedMessages: [ChatMessage] = CoachView.defaultMessages()
    @State private var inputText = ""
    @State private var showInput = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        ZStack {
            Color.ccBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Coach header
                coachHeader

                // Messages
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: CCSpacing.lg) {
                            // Daily verdict
                            dailyVerdictCard
                                .padding(.horizontal, CCSpacing.xl)
                                .padding(.top, CCSpacing.xl)

                            // Chat messages
                            ForEach(displayedMessages) { msg in
                                messageBubble(msg)
                                    .padding(.horizontal, CCSpacing.xl)
                                    .id(msg.id)
                            }

                            if isThinking {
                                thinkingIndicator
                                    .padding(.horizontal, CCSpacing.xl)
                            }
                        }
                        .padding(.bottom, 140)
                    }
                    .onChange(of: displayedMessages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(displayedMessages.last?.id, anchor: .bottom)
                        }
                    }
                }

                // Quick prompts + input
                bottomBar
            }
        }
    }

    // MARK: - Coach Header
    var coachHeader: some View {
        HStack(spacing: CCSpacing.lg) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.ccAccentDim)
                    .frame(width: 48, height: 48)

                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.ccAccent)
            }
            .overlay(
                Circle()
                    .fill(Color.ccGreen)
                    .frame(width: 12, height: 12)
                    .offset(x: 17, y: 17)
            )
            .ccGlow()

            VStack(alignment: .leading, spacing: 2) {
                Text("Coach")
                    .font(CCFont.display(18, weight: .bold))
                    .foregroundColor(.ccTextPrimary)
                Text("Online · Strict mode")
                    .font(CCFont.body(12))
                    .foregroundColor(.ccGreen)
            }

            Spacer()

            CCBadge(text: "Day 7", color: .ccAccent)
        }
        .padding(.horizontal, CCSpacing.xl)
        .padding(.top, 60)
        .padding(.bottom, CCSpacing.xl)
        .background(Color.ccBackground)
    }

    // MARK: - Daily Verdict
    var dailyVerdictCard: some View {
        let msg = appVM.coachFeedback(for: appVM.todayLog)
        let adherence = appVM.computeAdherence(log: appVM.todayLog)

        return VStack(alignment: .leading, spacing: CCSpacing.lg) {
            HStack(spacing: CCSpacing.md) {
                Image(systemName: msg.toneIcon)
                    .font(.system(size: 20))
                    .foregroundColor(msg.toneColor)
                Text("Today's Verdict")
                    .font(CCFont.display(16, weight: .bold))
                    .foregroundColor(.ccTextPrimary)
                Spacer()
                Text("\(adherence)/100")
                    .font(CCFont.mono(16, weight: .heavy))
                    .foregroundColor(msg.toneColor)
            }

            Text(msg.headline)
                .font(CCFont.display(20, weight: .heavy))
                .foregroundColor(.ccTextPrimary)

            Text(msg.body)
                .font(CCFont.body(14))
                .foregroundColor(.ccTextSecondary)
                .lineSpacing(4)

            CCDivider()

            // Key metrics
            HStack(spacing: 0) {
                verdictStat("Protein", value: "\(Int(appVM.todayLog.proteinG))g", target: "170g", ok: appVM.todayLog.proteinG >= 150)
                Divider().frame(width: 0.5).background(Color.ccBorder)
                verdictStat("Calories", value: "\(appVM.todayLog.calories)", target: "1900", ok: appVM.todayLog.calories >= 1700 && appVM.todayLog.calories <= 2100)
                Divider().frame(width: 0.5).background(Color.ccBorder)
                verdictStat("Steps", value: "\(appVM.todayLog.steps.formatted())", target: "10k", ok: appVM.todayLog.steps >= 10000)
                Divider().frame(width: 0.5).background(Color.ccBorder)
                verdictStat("Water", value: "\(String(format: "%.1f", appVM.todayLog.waterL))L", target: "4.5L", ok: appVM.todayLog.waterL >= 4.0)
            }
        }
        .padding(CCSpacing.xl)
        .background(
            ZStack {
                Color.ccCard
                LinearGradient(colors: [msg.toneColor.opacity(0.07), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: CCRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: CCRadius.lg).stroke(msg.toneColor.opacity(0.3), lineWidth: 1))
    }

    func verdictStat(_ label: String, value: String, target: String, ok: Bool) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(CCFont.mono(14, weight: .bold))
                .foregroundColor(ok ? .ccGreen : .ccRed)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(target)
                .font(CCFont.body(10))
                .foregroundColor(.ccTextTertiary)
            Text(label)
                .font(CCFont.body(10))
                .foregroundColor(.ccTextSecondary)
            Image(systemName: ok ? "checkmark" : "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(ok ? .ccGreen : .ccRed)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CCSpacing.sm)
    }

    // MARK: - Message Bubble
    func messageBubble(_ msg: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: CCSpacing.md) {
            if msg.isUser { Spacer() }

            if !msg.isUser {
                // Coach avatar small
                ZStack {
                    Circle().fill(Color.ccAccentDim).frame(width: 28, height: 28)
                    Image(systemName: "flame.fill").font(.system(size: 12, weight: .bold)).foregroundColor(.ccAccent)
                }
            }

            VStack(alignment: msg.isUser ? .trailing : .leading, spacing: 4) {
                Text(msg.text)
                    .font(CCFont.body(14))
                    .foregroundColor(msg.isUser ? .ccBackground : .ccTextPrimary)
                    .padding(.horizontal, CCSpacing.lg)
                    .padding(.vertical, CCSpacing.md)
                    .background(msg.isUser ? Color.ccAccent : Color.ccCard)
                    .clipShape(RoundedRectangle(cornerRadius: CCRadius.md))
                    .lineSpacing(3)

                Text(msg.time)
                    .font(CCFont.body(10))
                    .foregroundColor(.ccTextTertiary)
            }

            if msg.isUser {
                // User avatar small
                ZStack {
                    Circle().fill(Color.ccBorder).frame(width: 28, height: 28)
                    Image(systemName: "person.fill").font(.system(size: 12)).foregroundColor(.ccTextSecondary)
                }
            } else {
                Spacer()
            }
        }
    }

    // MARK: - Thinking Indicator
    var thinkingIndicator: some View {
        HStack(spacing: CCSpacing.md) {
            ZStack {
                Circle().fill(Color.ccAccentDim).frame(width: 28, height: 28)
                Image(systemName: "flame.fill").font(.system(size: 12, weight: .bold)).foregroundColor(.ccAccent)
            }

            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.ccTextTertiary)
                        .frame(width: 6, height: 6)
                        .scaleEffect(isThinking ? 1.4 : 0.8)
                        .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15), value: isThinking)
                }
            }
            .padding(.horizontal, CCSpacing.lg)
            .padding(.vertical, CCSpacing.md)
            .background(Color.ccCard)
            .clipShape(RoundedRectangle(cornerRadius: CCRadius.md))

            Spacer()
        }
        .onAppear { isThinking = true }
        .onDisappear { isThinking = false }
    }

    // MARK: - Bottom Bar
    var bottomBar: some View {
        VStack(spacing: CCSpacing.md) {
            // Quick prompts
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CCSpacing.sm) {
                    ForEach(quickPrompts, id: \.self) { prompt in
                        Button {
                            sendMessage(prompt)
                        } label: {
                            Text(prompt)
                                .font(CCFont.body(13))
                                .foregroundColor(.ccTextSecondary)
                                .padding(.horizontal, CCSpacing.md)
                                .padding(.vertical, CCSpacing.sm)
                                .background(Color.ccCard)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.ccBorder, lineWidth: 0.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, CCSpacing.xl)
            }

            // Text input
            HStack(spacing: CCSpacing.md) {
                TextField("Ask your coach...", text: $inputText)
                    .font(CCFont.body(15))
                    .foregroundColor(.ccTextPrimary)
                    .tint(.ccAccent)
                    .focused($inputFocused)
                    .padding(.horizontal, CCSpacing.lg)
                    .padding(.vertical, CCSpacing.md)
                    .background(Color.ccCard)
                    .clipShape(RoundedRectangle(cornerRadius: CCRadius.pill))
                    .overlay(RoundedRectangle(cornerRadius: CCRadius.pill).stroke(Color.ccBorder))

                Button {
                    guard !inputText.isEmpty else { return }
                    sendMessage(inputText)
                    inputText = ""
                    inputFocused = false
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.ccBackground)
                        .frame(width: 44, height: 44)
                        .background(Color.ccAccent)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(inputText.isEmpty)
                .opacity(inputText.isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, CCSpacing.xl)
        }
        .padding(.bottom, 100)
        .padding(.top, CCSpacing.md)
        .background(Color.ccBackground)
        .overlay(alignment: .top) { CCDivider() }
    }

    let quickPrompts = [
        "How's my progress?",
        "Meal advice today",
        "Should I do cardio?",
        "Am I in deficit?",
        "Protein tips",
    ]

    func sendMessage(_ text: String) {
        let userMsg = ChatMessage(text: text, isUser: true)
        withAnimation { displayedMessages.append(userMsg) }

        // Simulate coach response
        let thinking = ChatMessage(text: "...", isUser: false, isThinking: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation { displayedMessages.append(thinking) }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { displayedMessages.removeAll { $0.isThinking } }
            let response = coachResponse(for: text)
            withAnimation { displayedMessages.append(ChatMessage(text: response, isUser: false)) }
        }
    }

    func coachResponse(for query: String) -> String {
        let q = query.lowercased()
        if q.contains("progress") || q.contains("doing") {
            return "You're \(String(format: "%.1f%%", appVM.progressPercent * 100)) through the cut. \(String(format: "%.1f", appVM.currentWeightKg - appVM.currentProfile.goalWeightKg)) kg to go. Pace needs to stay consistent. No slack."
        }
        if q.contains("meal") || q.contains("eat") || q.contains("food") {
            return "Focus: protein first. Every meal. Chicken, paneer, eggs. Don't touch processed food. Follow the plan I set — it's designed specifically for your deficit."
        }
        if q.contains("cardio") {
            return "Yes. 30–45 min today. Fasted preferred. If gym session done, do 20 min post-weights. Your NEAT is your biggest fat-loss lever right now."
        }
        if q.contains("deficit") {
            return "At 1900 kcal with your TDEE (~2800 kcal), you're in a ~900 kcal daily deficit. Combined with steps and cardio that's 1100–1300 deficit. Right where you need to be."
        }
        if q.contains("protein") {
            return "170g daily. That's the floor. Chicken breast, whey, egg whites, paneer, yogurt. Space it across 4–5 meals. Don't front-load it — spread it for maximum synthesis."
        }
        return "Stay on plan. Log everything. Hit your steps. That's all there is to it — execution, not complexity."
    }

    static func defaultMessages() -> [ChatMessage] {
        [
            ChatMessage(text: "Abhinav. Day 7. Here's where you stand.", isUser: false),
            ChatMessage(text: "You're down 2.4 kg in a week. Solid start. But protein is still averaging 15g below target. Fix that or you'll lose muscle, not fat.", isUser: false),
            ChatMessage(text: "What should I prioritize today?", isUser: true),
            ChatMessage(text: "In order: 1) Hit 170g protein. 2) 10k steps — non-negotiable. 3) Drink 4L water before 9pm. 4) Gym session. Everything else is secondary.", isUser: false),
        ]
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var isThinking: Bool = false
    let time: String

    init(text: String, isUser: Bool, isThinking: Bool = false) {
        self.text = text
        self.isUser = isUser
        self.isThinking = isThinking
        self.time = Date().formatted(date: .omitted, time: .shortened)
    }
}
