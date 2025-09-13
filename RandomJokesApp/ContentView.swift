//
//  ContentView.swift
//  RandomJokesApp
//
//  Created by  Dhruvv on 14/09/25.
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Missing Type Definitions
enum VoiceType {
    case defaultVoice, funny, dramatic, robot
    
    var rate: Float {
        switch self {
        case .defaultVoice: return 0.15
        case .funny: return 0.18
        case .dramatic: return 0.12
        case .robot: return 0.1
        }
    }
    
    var pitch: Float {
        switch self {
        case .defaultVoice: return 1.0
        case .funny: return 1.3
        case .dramatic: return 0.8
        case .robot: return 0.7
        }
    }
    
    var identifier: String? {
        switch self {
        case .defaultVoice: return nil
        case .funny: return "com.apple.speech.synthesis.voice.Alex"
        case .dramatic: return "com.apple.speech.synthesis.voice.Fred"
        case .robot: return "com.apple.speech.synthesis.voice.Victoria"
        }
    }
}

enum SwipeDirection {
    case left, right
}

struct SwipeableJokeCard {
    let joke: Joke
    let id = UUID()
}

// MARK: - Theme System
enum AppTheme: String, CaseIterable {
    case funNeon = "Fun Neon"
    case minimalWhite = "Minimal White"
    case darkGlow = "Dark Glow"
    case classic = "Classic"
}

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var gradientAnimation: CGFloat = 0
    @Published var currentTheme: AppTheme = .classic
    @Published var soundEnabled: Bool = true
    @Published var accessibilityLargeText: Bool = false
    @Published var accessibilityHighContrast: Bool = false
    
    init() {
        loadSettings()
        // Start gradient animation
        withAnimation(.easeInOut(duration: 8).repeatForever()) {
            gradientAnimation = 1
        }
    }
    
    private func loadSettings() {
        if let themeRaw = UserDefaults.standard.string(forKey: "AppTheme"),
           let theme = AppTheme(rawValue: themeRaw) {
            currentTheme = theme
        }
        soundEnabled = UserDefaults.standard.bool(forKey: "SoundEnabled")
        accessibilityLargeText = UserDefaults.standard.bool(forKey: "AccessibilityLargeText")
        accessibilityHighContrast = UserDefaults.standard.bool(forKey: "AccessibilityHighContrast")
    }
    
    func saveSettings() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: "AppTheme")
        UserDefaults.standard.set(soundEnabled, forKey: "SoundEnabled")
        UserDefaults.standard.set(accessibilityLargeText, forKey: "AccessibilityLargeText")
        UserDefaults.standard.set(accessibilityHighContrast, forKey: "AccessibilityHighContrast")
    }
    
    func updateAppIcon(for streak: Int) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        
        let iconName: String?
        
        switch streak {
        case 0...2:
            iconName = nil // Default icon
        case 3...6:
            iconName = "AppIcon-Fire" // Fire streak icon
        case 7...13:
            iconName = "AppIcon-Star" // Star achiever icon
        case 14...29:
            iconName = "AppIcon-Crown" // Crown master icon
        default:
            iconName = "AppIcon-Legend" // Legend icon
        }
        
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Failed to update app icon: \(error.localizedDescription)")
            }
        }
    }
    
    var primaryGradient: LinearGradient {
        switch currentTheme {
        case .funNeon:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.0, blue: 1.0), // Neon Pink
                    Color(red: 0.0, green: 1.0, blue: 1.0), // Neon Cyan
                    Color(red: 1.0, green: 1.0, blue: 0.0)  // Neon Yellow
                ]),
                startPoint: gradientAnimation == 0 ? .topLeading : .bottomTrailing,
                endPoint: gradientAnimation == 0 ? .bottomTrailing : .topLeading
            )
        case .minimalWhite:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.95, blue: 0.97), // Light Gray
                    Color(red: 0.98, green: 0.98, blue: 1.0),   // Very Light Blue
                    Color(red: 0.97, green: 0.97, blue: 0.99)   // Light Purple
                ]),
                startPoint: gradientAnimation == 0 ? .topLeading : .bottomTrailing,
                endPoint: gradientAnimation == 0 ? .bottomTrailing : .topLeading
            )
        case .darkGlow:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.0, blue: 0.2), // Dark Purple
                    Color(red: 0.0, green: 0.1, blue: 0.3), // Dark Blue
                    Color(red: 0.2, green: 0.0, blue: 0.1)  // Dark Red
                ]),
                startPoint: gradientAnimation == 0 ? .topLeading : .bottomTrailing,
                endPoint: gradientAnimation == 0 ? .bottomTrailing : .topLeading
            )
        case .classic:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.6, green: 0.2, blue: 0.9), // Purple
                    Color(red: 0.2, green: 0.4, blue: 0.9), // Blue
                    Color(red: 0.9, green: 0.2, blue: 0.6)  // Pink
                ]),
                startPoint: gradientAnimation == 0 ? .topLeading : .bottomTrailing,
                endPoint: gradientAnimation == 0 ? .bottomTrailing : .topLeading
            )
        }
    }
    
    var cardBackground: Color {
        switch currentTheme {
        case .funNeon:
            return isDarkMode ? Color.black.opacity(0.3) : Color.white.opacity(0.2)
        case .minimalWhite:
            return Color.white.opacity(0.9)
        case .darkGlow:
            return Color.black.opacity(0.4)
        case .classic:
            return isDarkMode ? Color.white.opacity(0.15) : Color.white.opacity(0.8)
        }
    }
    
    var cardBorder: Color {
        switch currentTheme {
        case .funNeon:
            return Color.white.opacity(0.6)
        case .minimalWhite:
            return Color.gray.opacity(0.2)
        case .darkGlow:
            return Color.white.opacity(0.1)
        case .classic:
            return isDarkMode ? Color.white.opacity(0.3) : Color.white.opacity(0.4)
        }
    }
    
    var cardShadow: Color {
        switch currentTheme {
        case .funNeon:
            return Color.cyan.opacity(0.3)
        case .minimalWhite:
            return Color.gray.opacity(0.1)
        case .darkGlow:
            return Color.purple.opacity(0.4)
        case .classic:
            return isDarkMode ? Color.black.opacity(0.3) : Color.black.opacity(0.1)
        }
    }
    
    var textPrimary: Color {
        if accessibilityHighContrast {
            return currentTheme == .minimalWhite ? Color.black : Color.white
        }
        switch currentTheme {
        case .funNeon:
            return Color.white
        case .minimalWhite:
            return Color.black
        case .darkGlow:
            return Color.white
        case .classic:
            return isDarkMode ? Color.white : Color.black
        }
    }
    
    var textSecondary: Color {
        if accessibilityHighContrast {
            return textPrimary.opacity(0.8)
        }
        switch currentTheme {
        case .funNeon:
            return Color.white.opacity(0.8)
        case .minimalWhite:
            return Color.black.opacity(0.6)
        case .darkGlow:
            return Color.white.opacity(0.7)
        case .classic:
            return isDarkMode ? Color.white.opacity(0.7) : Color.black.opacity(0.6)
        }
    }
}

// MARK: - Floating Emoji Particles System
struct FloatingEmojiParticles: View {
    @State private var particles: [EmojiParticle] = []
    let emojis = ["😂", "🤣", "😎", "🎭", "✨", "💫", "🌟"]
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Text(particle.emoji)
                    .font(.system(size: particle.size))
                    .opacity(particle.opacity)
                    .position(x: particle.x, y: particle.y)
                    .animation(
                        .easeInOut(duration: particle.duration)
                        .repeatForever(autoreverses: false),
                        value: particle.y
                    )
            }
        }
        .onAppear {
            startParticleAnimation()
        }
        .allowsHitTesting(false)
    }
    
    private func startParticleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            addNewParticle()
        }
        
        // Add initial particles
        for _ in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...2)) {
                addNewParticle()
            }
        }
    }
    
    private func addNewParticle() {
        let newParticle = EmojiParticle(
            emoji: emojis.randomElement() ?? "😂",
            x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
            y: UIScreen.main.bounds.height + 50,
            size: CGFloat.random(in: 16...24),
            opacity: Double.random(in: 0.3...0.7),
            duration: Double.random(in: 8...15)
        )
        
        particles.append(newParticle)
        
        withAnimation(.easeInOut(duration: newParticle.duration)) {
            if let index = particles.firstIndex(where: { $0.id == newParticle.id }) {
                particles[index].y = -100
                particles[index].x += CGFloat.random(in: -30...30)
            }
        }
        
        // Remove particle after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + newParticle.duration) {
            particles.removeAll { $0.id == newParticle.id }
        }
    }
}

struct EmojiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let opacity: Double
    let duration: Double
}

// MARK: - Enhanced Confetti System
struct ConfettiView: View {
    @State private var animate = false
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .pink, .orange]
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                Circle()
                    .fill(colors.randomElement() ?? .blue)
                    .frame(width: CGFloat.random(in: 4...8))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: animate ? UIScreen.main.bounds.height + 100 : -100
                    )
                    .animation(
                        .easeOut(duration: Double.random(in: 2...4))
                        .delay(Double.random(in: 0...0.5)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Emoji Explosion View
struct EmojiExplosionView: View {
    @State private var animate = false
    let emojis = ["❤️", "💖", "💕", "💘", "💝", "💗", "💓", "💞", "💟"]
    
    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { index in
                Text(emojis.randomElement() ?? "❤️")
                    .font(.system(size: CGFloat.random(in: 20...35)))
                    .position(
                        x: animate ? CGFloat.random(in: 0...UIScreen.main.bounds.width) : UIScreen.main.bounds.width / 2,
                        y: animate ? CGFloat.random(in: 0...UIScreen.main.bounds.height) : UIScreen.main.bounds.height / 2
                    )
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 2.0 : 0.5)
                    .animation(
                        .easeOut(duration: Double.random(in: 1...2))
                        .delay(Double.random(in: 0...0.3)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Sound Effects Manager
class SoundManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    func playSound(_ soundName: String) {
        guard let path = Bundle.main.path(forResource: soundName, ofType: "mp3") else {
            // Fallback to system sounds
            playSystemSound()
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            playSystemSound()
        }
    }
    
    private func playSystemSound() {
        // Use system haptic feedback as fallback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

// MARK: - Ripple Effect Button
struct RippleEffect: View {
    @State private var animate = false
    let color: Color
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .scaleEffect(animate ? 2.0 : 0.0)
            .opacity(animate ? 0.0 : 1.0)
            .animation(.easeOut(duration: 0.6), value: animate)
            .onAppear {
                animate = true
            }
    }
}

struct RippleButtonStyle: ButtonStyle {
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var soundManager = SoundManager()
    @State private var showRipple = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    theme.primaryGradient
                        .overlay(
                            .white.opacity(configuration.isPressed ? 0.2 : 0)
                        )
                    
                    if showRipple {
                        RippleEffect(color: .white)
                    }
                }
            )
            .foregroundColor(.white)
            .font(.system(size: theme.accessibilityLargeText ? 22 : 18, weight: .bold, design: .rounded))
            .cornerRadius(25)
            .shadow(
                color: theme.cardShadow,
                radius: configuration.isPressed ? 5 : 15,
                x: 0,
                y: configuration.isPressed ? 2 : 8
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed {
                    if theme.soundEnabled {
                        soundManager.playSound("pop")
                    }
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    showRipple = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showRipple = false
                    }
                }
            }
    }
}

// MARK: - Glassmorphism Card
struct GlassmorphicCard<Content: View>: View {
    let content: Content
    @EnvironmentObject var theme: ThemeManager
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .background(theme.cardBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(theme.cardBorder, lineWidth: 1.5)
            )
            .shadow(color: theme.cardShadow, radius: theme.isDarkMode ? 25 : 20, x: 0, y: theme.isDarkMode ? 12 : 10)
    }
}

// MARK: - Modern Button Style (Enhanced)
struct ModernButtonStyle: ButtonStyle {
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var soundManager = SoundManager()
    @State private var showRipple = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    theme.primaryGradient
                        .overlay(
                            .white.opacity(configuration.isPressed ? 0.2 : 0)
                        )
                    
                    if showRipple {
                        RippleEffect(color: .white)
                    }
                }
            )
            .foregroundColor(.white)
            .font(.system(size: theme.accessibilityLargeText ? 22 : 18, weight: .bold, design: .rounded))
            .cornerRadius(25)
            .shadow(
                color: theme.cardShadow,
                radius: configuration.isPressed ? 5 : 15,
                x: 0,
                y: configuration.isPressed ? 2 : 8
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed {
                    if theme.soundEnabled {
                        soundManager.playSound("pop")
                    }
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    showRipple = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showRipple = false
                    }
                }
            }
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double
    let color: Color
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.3),
                    lineWidth: 8
                )
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animatedProgress = progress
            }
        }
    }
}

// MARK: - Models
struct Joke: Codable, Identifiable, Equatable {
    let id: Int
    let type: String
    let setup: String
    let punchline: String
    
    static func == (lhs: Joke, rhs: Joke) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Achievement: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let isUnlocked: Bool
    let unlockedDate: Date?
    
    static let allAchievements = [
        Achievement(id: "first_joke", title: "First Laugh", description: "Read your first joke", emoji: "😄", isUnlocked: false, unlockedDate: nil),
        Achievement(id: "joke_master", title: "Joke Master", description: "Read 10 jokes", emoji: "🎭", isUnlocked: false, unlockedDate: nil),
        Achievement(id: "comedy_king", title: "Comedy King", description: "Read 50 jokes", emoji: "👑", isUnlocked: false, unlockedDate: nil),
        Achievement(id: "first_favorite", title: "Favorite Fun", description: "Add your first favorite", emoji: "❤️", isUnlocked: false, unlockedDate: nil),
        Achievement(id: "streak_week", title: "Week Warrior", description: "7-day reading streak", emoji: "🔥", isUnlocked: false, unlockedDate: nil)
    ]
}

// MARK: - API Service
class JokeService: ObservableObject {
    private let apiURL = "https://official-joke-api.appspot.com/random_joke"
    private var cancellables = Set<AnyCancellable>()
    
    func fetchJoke() -> AnyPublisher<Joke, Error> {
        guard let url = URL(string: apiURL) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Joke.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

class VoiceNarrationManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isNarrating = false
    private let synthesizer = AVSpeechSynthesizer()
    @Published var voiceEnabled = UserDefaults.standard.bool(forKey: "VoiceEnabled")
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isNarrating = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isNarrating = false
        }
    }
    
    func narrate(_ text: String, voice: VoiceType = .defaultVoice) {
        synthesizer.stopSpeaking(at: .immediate)
        
        // Split joke into setup and punchline for dramatic effect
        let parts = text.components(separatedBy: ". ")
        let setup = parts.first ?? text
        let punchline = parts.count > 1 ? parts.dropFirst().joined(separator: ". ") : ""
        
        // Create narrative introduction
        let narrativeText = "Here's a funny joke for you... \(setup)... ... ... And here comes the punchline... \(punchline)! Ha ha ha!"
        
        let utterance = AVSpeechUtterance(string: narrativeText)
        utterance.rate = 0.3  // Slightly faster for better flow
        utterance.pitchMultiplier = 1.5  // Even higher pitch for comedy
        utterance.volume = 0.9
        
        // Use the most expressive voice available
        if let funnyVoice = AVSpeechSynthesisVoice(identifier: "com.apple.speech.synthesis.voice.Alex") {
            utterance.voice = funnyVoice
        }
        
        isNarrating = true
        synthesizer.speak(utterance)
    }
    
    func stopNarration() {
        synthesizer.stopSpeaking(at: .immediate)
        isNarrating = false
    }
    
    func toggleVoice() {
        voiceEnabled.toggle()
        UserDefaults.standard.set(voiceEnabled, forKey: "VoiceEnabled")
        if !voiceEnabled {
            stopNarration()
        }
    }
}

// MARK: - Enhanced ViewModel
class JokeViewModel: ObservableObject {
    @Published var joke: Joke?
    @Published var favoriteJokes: [Joke] = []
    @Published var recentJokes: [Joke] = []
    @Published var jokesReadCount: Int = 0
    @Published var currentStreak: Int = 0
    @Published var swipeableCards: [SwipeableJokeCard] = []
    @Published var currentCardIndex = 0
    @Published var isLoading = false
    @Published var achievements: [Achievement] = []
    @Published var dailyJokesRead: [Date: Int] = [:]
    @Published var showEmojiExplosion = false
    @Published var showConfetti = false
    @Published var jokeReaction = ""
    @Published var isFlipped = false
    
    var errorMessage: String?
    
    // UserDefaults keys
    private let favoritesKey = "FavoriteJokes"
    private let jokesReadKey = "JokesReadCount"
    private let streakKey = "CurrentStreak"
    private let lastReadDateKey = "LastReadDate"
    private let achievementsKey = "Achievements"
    private let dailyJokesKey = "DailyJokesRead"
    private let memberSinceKey = "MemberSince"
    
    private let jokeService = JokeService()
    private var cancellables = Set<AnyCancellable>()
    let voiceManager = VoiceNarrationManager()
    
    init() {
        // Initial state
        errorMessage = nil
        loadFavorites()
        loadJokesReadCount()
        loadStreak()
        loadAchievements()
        loadDailyJokes()
        setMemberSinceIfNeeded()
        preloadJokes()
    }
    
    // MARK: - Swipeable Cards Management
    func preloadJokes() {
        // Load initial set of jokes for swiping
        for _ in 0..<3 {
            fetchJokeForSwipe()
        }
    }
    
    private func fetchJokeForSwipe() {
        jokeService.fetchJoke()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching joke for swipe: \(error)")
                    }
                },
                receiveValue: { [weak self] newJoke in
                    let swipeableCard = SwipeableJokeCard(joke: newJoke)
                    self?.swipeableCards.append(swipeableCard)
                }
            )
            .store(in: &cancellables)
    }
    
    func swipeCard(direction: SwipeDirection) {
        guard currentCardIndex < swipeableCards.count else { return }
        
        let currentCard = swipeableCards[currentCardIndex]
        
        switch direction {
        case .right: // Favorite
            addToFavorites(currentCard.joke)
            showEmojiExplosion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showEmojiExplosion = false
            }
        case .left: // Skip
            break
        }
        
        // Move to next card
        currentCardIndex += 1
        incrementJokesRead()
        
        // Preload more jokes if needed
        if swipeableCards.count - currentCardIndex < 2 {
            fetchJokeForSwipe()
        }
    }
    
    func getCurrentCard() -> SwipeableJokeCard? {
        guard currentCardIndex < swipeableCards.count else { return nil }
        return swipeableCards[currentCardIndex]
    }
    
    func getNextCard() -> SwipeableJokeCard? {
        let nextIndex = currentCardIndex + 1
        guard nextIndex < swipeableCards.count else { return nil }
        return swipeableCards[nextIndex]
    }
    
    // MARK: - Daily Jokes Tracking
    private func loadDailyJokes() {
        if let data = UserDefaults.standard.data(forKey: dailyJokesKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            dailyJokesRead = Dictionary(uniqueKeysWithValues: decoded.map { (key, value) in
                (formatter.date(from: key) ?? Date(), value)
            })
        }
    }
    
    private func saveDailyJokes() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let stringDict = Dictionary(uniqueKeysWithValues: dailyJokesRead.map { (key, value) in
            (formatter.string(from: key), value)
        })
        if let encoded = try? JSONEncoder().encode(stringDict) {
            UserDefaults.standard.set(encoded, forKey: dailyJokesKey)
        }
    }
    
    private func updateDailyJokes() {
        let today = Calendar.current.startOfDay(for: Date())
        dailyJokesRead[today, default: 0] += 1
        saveDailyJokes()
    }
    
    
    func incrementJokesRead() {
        jokesReadCount += 1
        updateStreak()
        updateDailyJokes()
        saveJokesReadCount()
        checkAchievements()
    }
    
    func fetchNewJoke() {
        isLoading = true
        
        guard let url = URL(string: "https://official-joke-api.appspot.com/random_joke") else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let data = data {
                    do {
                        let jokeResponse = try JSONDecoder().decode(Joke.self, from: data)
                        self?.joke = jokeResponse
                        // Add to recent jokes
                        if let joke = self?.joke {
                            self?.recentJokes.insert(joke, at: 0)
                            if self?.recentJokes.count ?? 0 > 10 {
                                self?.recentJokes.removeLast()
                            }
                        }
                    } catch {
                        print("Error decoding joke: \(error)")
                    }
                }
            }
        }.resume()
    }
    
    // MARK: - Favorites Management
    func addToFavorites(_ joke: Joke) {
        if !favoriteJokes.contains(joke) {
            favoriteJokes.append(joke)
            saveFavorites()
            checkAchievements()
            
            // Show confetti for favorites
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showConfetti = false
            }
        }
    }
    
    func removeFromFavorites(_ joke: Joke) {
        favoriteJokes.removeAll { $0.id == joke.id }
        saveFavorites()
    }
    
    func isFavorite(_ joke: Joke) -> Bool {
        return favoriteJokes.contains(joke)
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteJokes) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Joke].self, from: data) {
            favoriteJokes = decoded
        }
    }
    
    // MARK: - Jokes Read Tracking
    private func saveJokesReadCount() {
        UserDefaults.standard.set(jokesReadCount, forKey: jokesReadKey)
    }
    
    private func loadJokesReadCount() {
        jokesReadCount = UserDefaults.standard.integer(forKey: jokesReadKey)
    }
    
    // Add bounce animation to emoji
    private func triggerJokeReaction() {
        withAnimation(.spring()) {
            jokeReaction = "😂"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.jokeReaction = ""
        }
    }
    
    func updateAppIconForStreak(_ themeManager: ThemeManager) {
        themeManager.updateAppIcon(for: currentStreak)
    }
    
    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastReadDate = UserDefaults.standard.object(forKey: lastReadDateKey) as? Date
        
        if let lastRead = lastReadDate {
            let lastReadDay = Calendar.current.startOfDay(for: lastRead)
            let daysBetween = Calendar.current.dateComponents([.day], from: lastReadDay, to: today).day ?? 0
            
            if daysBetween == 1 {
                // Continue streak
                currentStreak += 1
            } else if daysBetween > 1 {
                // Reset streak
                currentStreak = 1
            }
            // If daysBetween == 0, same day, don't change streak
        } else {
            // First time reading
            currentStreak = 1
        }
        
        UserDefaults.standard.set(Date(), forKey: lastReadDateKey)
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
    }
    
    private func loadStreak() {
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
    }
    
    // MARK: - Member Since Tracking
    private func setMemberSinceIfNeeded() {
        if UserDefaults.standard.object(forKey: memberSinceKey) == nil {
            UserDefaults.standard.set(Date(), forKey: memberSinceKey)
        }
    }
    
    func getMemberSinceDate() -> Date {
        return UserDefaults.standard.object(forKey: memberSinceKey) as? Date ?? Date()
    }
    
    // MARK: - Achievement System
    private func checkAchievements() {
        var newAchievements: [Achievement] = []
        
        // Check various achievement conditions
        if jokesReadCount == 1 && !isAchievementUnlocked("first_joke") {
            newAchievements.append(unlockAchievement("first_joke"))
        }
        
        if jokesReadCount == 10 && !isAchievementUnlocked("joke_master") {
            newAchievements.append(unlockAchievement("joke_master"))
        }
        
        if jokesReadCount == 50 && !isAchievementUnlocked("comedy_king") {
            newAchievements.append(unlockAchievement("comedy_king"))
        }
        
        if favoriteJokes.count == 1 && !isAchievementUnlocked("first_favorite") {
            newAchievements.append(unlockAchievement("first_favorite"))
        }
        
        if currentStreak >= 7 && !isAchievementUnlocked("streak_week") {
            newAchievements.append(unlockAchievement("streak_week"))
        }
        
        if !newAchievements.isEmpty {
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showConfetti = false
            }
        }
    }
    
    private func isAchievementUnlocked(_ id: String) -> Bool {
        return achievements.first(where: { $0.id == id })?.isUnlocked ?? false
    }
    
    private func unlockAchievement(_ id: String) -> Achievement {
        let template = Achievement.allAchievements.first(where: { $0.id == id })!
        let unlockedAchievement = Achievement(
            id: template.id,
            title: template.title,
            description: template.description,
            emoji: template.emoji,
            isUnlocked: true,
            unlockedDate: Date()
        )
        
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index] = unlockedAchievement
        } else {
            achievements.append(unlockedAchievement)
        }
        
        saveAchievements()
        return unlockedAchievement
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            // Initialize with template achievements
            achievements = Achievement.allAchievements
        }
    }
    
    // MARK: - Joke Reactions & Flip Animation
    func flipCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isFlipped.toggle()
        }
    }
    
    func addReaction(_ emoji: String) {
        jokeReaction = emoji
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.jokeReaction = ""
        }
    }
    
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var viewModel = JokeViewModel()
    @StateObject private var themeManager = ThemeManager()
    @State private var showSplash = true
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Animated gradient background
            themeManager.primaryGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 8).repeatForever(), value: themeManager.gradientAnimation)
            
            if showSplash {
                ModernSplashView()
                    .environmentObject(themeManager)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                ZStack {
                    // Main content
                    ZStack {
                        if selectedTab == 1 {
                            CentralJokesView(viewModel: viewModel)
                                .environmentObject(themeManager)
                        } else if selectedTab == 0 {
                            ModernHomeView(viewModel: viewModel)
                                .environmentObject(themeManager)
                        } else if selectedTab == 2 {
                            ModernFavoritesView(viewModel: viewModel)
                                .environmentObject(themeManager)
                        } else if selectedTab == 3 {
                            ModernProfileView(viewModel: viewModel)
                                .environmentObject(themeManager)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Custom floating tab bar
                    VStack {
                        Spacer()
                        FloatingTabBar(selectedTab: $selectedTab)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 34)
                    }
                }
            }
            
            // Floating emoji particles
            FloatingEmojiParticles()
                .allowsHitTesting(false)
            
            // Confetti overlay
            if viewModel.showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
            
            // Emoji explosion for favorites
            if viewModel.showEmojiExplosion {
                EmojiExplosionView()
                    .allowsHitTesting(false)
            }
        }
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.currentTheme == .minimalWhite ? .light : (themeManager.isDarkMode ? .dark : .light))
    }
}

// MARK: - Central Jokes View (Redesigned)
struct CentralJokesView: View {
    @ObservedObject var viewModel: JokeViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var currentJokeId: Int?
    @State private var showingCard = false
    @State private var cardOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            headerSection
                .padding(.top, 20)
            
            Spacer()
            
            // Central joke card
            ZStack {
                if let joke = viewModel.joke {
                    CentralJokeCardView(
                        joke: joke,
                        voiceManager: viewModel.voiceManager,
                        onFavorite: {
                            viewModel.addToFavorites(joke)
                        }
                    )
                    .offset(x: cardOffset)
                    .id(joke.id) // Important for proper animation
                } else if viewModel.isLoading {
                    loadingCard
                } else {
                    emptyStateCard
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Get New Joke button
            GlowingGradientButton(title: "Get New Joke 🎲") {
                fetchNewJokeWithAnimation()
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // Extra padding for floating tab bar
        }
        .onAppear {
            if viewModel.joke == nil {
                viewModel.fetchNewJoke()
            }
        }
    }
    
    private func fetchNewJokeWithAnimation() {
        // Animate current card out
        withAnimation(.easeInOut(duration: 0.4)) {
            cardOffset = -UIScreen.main.bounds.width
        }
        
        // Fetch new joke after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            viewModel.fetchNewJoke()
            cardOffset = UIScreen.main.bounds.width
            
            // Animate new card in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                cardOffset = 0
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Random Jokes 🎭")
                .font(.system(size: theme.accessibilityLargeText ? 32 : 28, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.6, green: 0.2, blue: 0.9),
                            Color(red: 0.2, green: 0.4, blue: 0.9),
                            Color(red: 0.9, green: 0.2, blue: 0.6)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Tap to reveal the punchline")
                .font(.system(size: theme.accessibilityLargeText ? 20 : 16, weight: .medium, design: .rounded))
                .foregroundColor(theme.textSecondary)
        }
    }
    
    private var loadingCard: some View {
        GlassmorphicCard {
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(theme.textPrimary)
                
                Text("Loading a great joke...")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(theme.textSecondary)
            }
            .frame(minHeight: 200)
        }
    }
    
    private var emptyStateCard: some View {
        GlassmorphicCard {
            VStack(spacing: 20) {
                Text("🎭")
                    .font(.system(size: 60))
                
                Text("No jokes yet!")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textPrimary)
                
                Text("Tap the button below to get started")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(minHeight: 200)
        }
    }
    
}

// MARK: - Modern Home View
struct ModernHomeView: View {
    @ObservedObject var viewModel: JokeViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var animateStats = false
    @State private var bounceEmoji = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Welcome Card
                welcomeCard
                
                // Stats Overview
                statsOverview
                
                // Quick Actions
                quickActions
                
                // Recent Activity
                recentActivity
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // Extra padding for floating tab bar
        }
    }
    
    // MARK: - Welcome Card
    private var welcomeCard: some View {
        GlassmorphicCard {
            VStack(spacing: 16) {
                // Animated emoji
                Text("🎭")
                    .font(.system(size: 60))
                    .scaleEffect(bounceEmoji ? 1.2 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6).repeatForever(), value: bounceEmoji)
                    .onAppear {
                        bounceEmoji = true
                    }
                
                VStack(spacing: 8) {
                    Text("Welcome Back!")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(theme.textPrimary)
                    
                    Text("Ready for some laughs?")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Stats Overview
    private var statsOverview: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            // Jokes Read Card
            GlassmorphicCard {
                VStack(spacing: 16) {
                    ZStack {
                        ProgressRing(
                            progress: min(Double(viewModel.jokesReadCount) / 100.0, 1.0),
                            color: .blue
                        )
                        .frame(width: 80, height: 80)
                        
                        VStack {
                            Text("\(viewModel.jokesReadCount)")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text("Jokes Read")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.textPrimary)
                        
                        Text("Goal: 100")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
            .scaleEffect(animateStats ? 1.0 : 0.8)
            .opacity(animateStats ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateStats)
            
            // Favorites Card
            GlassmorphicCard {
                VStack(spacing: 16) {
                    ZStack {
                        ProgressRing(
                            progress: min(Double(viewModel.favoriteJokes.count) / 50.0, 1.0),
                            color: .red
                        )
                        .frame(width: 80, height: 80)
                        
                        VStack {
                            Text("\(viewModel.favoriteJokes.count)")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.red)
                            
                            Text("❤️")
                                .font(.system(size: 16))
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text("Favorites")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(theme.textPrimary)
                        
                        Text("Your best picks")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(theme.textSecondary)
                    }
                }
            }
            .scaleEffect(animateStats ? 1.0 : 0.8)
            .opacity(animateStats ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateStats)
        }
        .onAppear {
            animateStats = true
        }
    }
    
    // MARK: - Quick Actions
    private var quickActions: some View {
        EmptyView()
    }
    
    // MARK: - Recent Activity
    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(theme.textPrimary)
                .padding(.leading, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.recentJokes.prefix(5)) { joke in
                        RecentJokeCard(joke: joke)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Recent Joke Card
    private func RecentJokeCard(joke: Joke) -> some View {
        GlassmorphicCard {
            VStack(spacing: 8) {
                Text(joke.setup)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(joke.punchline)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120)
        }
    }
}

// MARK: - Modern Favorites View
struct ModernFavoritesView: View {
    @ObservedObject var viewModel: JokeViewModel
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            headerSection
                .padding(.top, 20)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.favoriteJokes, id: \.id) { joke in
                        FavoriteJokeCard(joke: joke) {
                            viewModel.removeFromFavorites(joke)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Extra padding for floating tab bar
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("My Favorites ❤️")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(theme.textPrimary)
            
            Text("\(viewModel.favoriteJokes.count) saved jokes")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(theme.textSecondary)
        }
    }
    
    // MARK: - Favorite Joke Card
    private func FavoriteJokeCard(joke: Joke, action: @escaping () -> Void) -> some View {
        GlassmorphicCard {
            VStack(spacing: 16) {
                // Setup
                Text(joke.setup)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Divider()
                    .background(theme.textSecondary.opacity(0.3))
                
                // Punchline
                Text(joke.punchline)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
                
                // Remove button
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.slash.fill")
                        Text("Remove")
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.red.opacity(0.1))
                    )
                }
            }
        }
    }
}

// MARK: - Modern Profile View
struct ModernProfileView: View {
    @ObservedObject var viewModel: JokeViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var showThemeToggle = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                profileHeader
                
                // Stats Section
                statsSection
                
                // Timeline Graph
                timelineSection
                
                // Settings Section
                settingsSection
                
                // Member Since
                memberSinceSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // Extra padding for floating tab bar
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        GlassmorphicCard {
            VStack(spacing: 16) {
                // Profile Avatar
                ZStack {
                    // Progress ring background
                    ProgressRing(
                        progress: min(Double(viewModel.jokesReadCount) / 100.0, 1.0),
                        color: .purple
                    )
                    .frame(width: 140, height: 140)
                    
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.purple,
                                        Color.blue,
                                        Color.cyan
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Text("😄")
                            .font(.system(size: 50))
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Joke Master")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textPrimary)
                    
                    Text("Level \(viewModel.jokesReadCount / 10 + 1)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.purple.opacity(0.1))
                        )
                }
            }
        }
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            // Jokes Read
            GlassmorphicCard {
                VStack(spacing: 8) {
                    Text("📚")
                        .font(.system(size: 30))
                    
                    Text("\(viewModel.jokesReadCount)")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(theme.textPrimary)
                    
                    Text("Jokes Read")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(theme.textSecondary)
                }
            }
            
            // Member Since
            GlassmorphicCard {
                VStack(spacing: 8) {
                    Text("📅")
                        .font(.system(size: 30))
                    
                    Text(formatMemberSince())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Member Since")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(theme.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Timeline Graph
    private var timelineSection: some View {
        TimelineGraphView(dailyData: viewModel.dailyJokesRead)
    }
    
    // MARK: - Member Since Section
    private var memberSinceSection: some View {
        GlassmorphicCard {
            VStack(spacing: 12) {
                Text("👋 Welcome!")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textPrimary)
                
                Text("Member since \(formatMemberSince())")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text("Thanks for being part of our joke community! 🎭")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        VStack(spacing: 16) {
            Text("Settings ⚙️")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            GlassmorphicCard {
                VStack(spacing: 20) {
                    // Theme Selection
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.purple)
                            // Day label
                            Text("Day")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(theme.textSecondary)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(AppTheme.allCases, id: \.self) { appTheme in
                                    Button(action: {
                                        theme.currentTheme = appTheme
                                        theme.saveSettings()
                                    }) {
                                        VStack(spacing: 8) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(themePreviewGradient(for: appTheme))
                                                .frame(width: 50, height: 30)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(theme.currentTheme == appTheme ? Color.blue : Color.clear, lineWidth: 2)
                                                )
                                            
                                            Text(appTheme.rawValue)
                                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                                .foregroundColor(theme.textSecondary)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    Divider()
                        .background(theme.textSecondary.opacity(0.3))
                    
                    // Dark Mode Toggle
                    HStack {
                        Image(systemName: theme.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                        
                        Text("Dark Mode")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(theme.textPrimary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $theme.isDarkMode)
                            .toggleStyle(SwitchToggleStyle(tint: .orange))
                            .onChange(of: theme.isDarkMode) { _, _ in
                                theme.saveSettings()
                            }
                    }
                    
                    
                    // Accessibility Options
                    HStack {
                        Image(systemName: "textformat.size")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                        
                        Text("Large Text")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(theme.textPrimary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $theme.accessibilityLargeText)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .onChange(of: theme.accessibilityLargeText) { _, _ in
                                theme.saveSettings()
                            }
                    }
                    
                }
            }
        }
    }
    
    private func formatMemberSince() -> String {
        let memberSince = UserDefaults.standard.object(forKey: "MemberSince") as? Date ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: memberSince)
    }
}

// MARK: - Theme Preview Helper
extension ModernProfileView {
    private func themePreviewGradient(for appTheme: AppTheme) -> LinearGradient {
        switch appTheme {
        case .funNeon:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.0, blue: 1.0),
                    Color(red: 0.0, green: 1.0, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .minimalWhite:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.95, blue: 0.97),
                    Color(red: 0.98, green: 0.98, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .darkGlow:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.0, blue: 0.2),
                    Color(red: 0.2, green: 0.0, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .classic:
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.6, green: 0.2, blue: 0.9),
                    Color(red: 0.9, green: 0.2, blue: 0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Missing View Components

// MARK: - Modern Splash View
struct ModernSplashView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var animateGradient = false
    @State private var bounceEmoji = false
    
    var body: some View {
        ZStack {
            // Animated background
            theme.primaryGradient
                .ignoresSafeArea()
                .hueRotation(.degrees(animateGradient ? 30 : 0))
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        animateGradient = true
                    }
                }
            
            VStack(spacing: 30) {
                // App icon/emoji
                Text("🎭")
                    .font(.system(size: 100))
                    .scaleEffect(bounceEmoji ? 1.2 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(), value: bounceEmoji)
                    .onAppear {
                        bounceEmoji = true
                    }
                
                VStack(spacing: 12) {
                    Text("Random Jokes")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Get ready to laugh!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Loading indicator
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var soundManager = SoundManager()
    
    private let tabs = [
        (icon: "house", selectedIcon: "house.fill", title: "Home"),
        (icon: "face.smiling", selectedIcon: "face.smiling.fill", title: "Jokes"),
        (icon: "heart", selectedIcon: "heart.fill", title: "Favorites"),
        (icon: "person", selectedIcon: "person.fill", title: "Profile")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    if theme.soundEnabled {
                        soundManager.playSound("pop")
                    }
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == index ? tabs[index].selectedIcon : tabs[index].icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
                            .scaleEffect(selectedTab == index ? 1.2 : 1.0)
                            .shadow(
                                color: selectedTab == index ? .white.opacity(0.8) : .clear,
                                radius: selectedTab == index ? 8 : 0
                            )
                        
                        Text(tabs[index].title)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedTab == index ? Color.white.opacity(0.2) : Color.clear)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 20,
                    x: 0,
                    y: 10
                )
        )
    }
}

// MARK: - Central Joke Card View
struct CentralJokeCardView: View {
    let joke: Joke
    let voiceManager: VoiceNarrationManager
    @State private var showPunchline = false
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0.0
    @State private var cardRotation: Double = 0
    @State private var showConfetti = false
    @EnvironmentObject var theme: ThemeManager
    let onFavorite: () -> Void
    
    var body: some View {
        GlassmorphicCard {
            VStack(spacing: 24) {
                if !showPunchline {
                    // Setup Phase
                    VStack(spacing: 20) {
                        Text("🎯 Setup")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .cyan]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(joke.setup)
                            .font(.system(size: theme.accessibilityLargeText ? 28 : 24, weight: .bold, design: .rounded))
                            .foregroundColor(theme.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .padding(.horizontal, 16)
                        
                        Button("Reveal Punchline 👆") {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                                showPunchline = true
                            }
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                } else {
                    // Punchline Phase
                    VStack(spacing: 20) {
                        Text("💫 Punchline")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.orange, .pink]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(joke.punchline)
                            .font(.system(size: theme.accessibilityLargeText ? 26 : 22, weight: .bold, design: .rounded))
                            .foregroundColor(theme.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .padding(.horizontal, 16)
                        
                        // Action buttons
                        HStack(spacing: 20) {
                            // Listen button
                            Button(action: {
                                let fullJoke = "\(joke.setup). \(joke.punchline)"
                                voiceManager.narrate(fullJoke, voice: .funny)
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: voiceManager.isNarrating ? "speaker.wave.2.fill" : "speaker.wave.2")
                                    Text(voiceManager.isNarrating ? "Playing..." : "Listen")
                                }
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.purple)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.purple.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .disabled(voiceManager.isNarrating)
                            
                            // Favorite button
                            Button(action: {
                                onFavorite()
                                triggerConfetti()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "heart.fill")
                                    Text("Favorite")
                                }
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.red.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        if voiceManager.isNarrating {
                            Button("Stop") {
                                voiceManager.stopNarration()
                            }
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .frame(minHeight: 350)
            .padding(24)
        }
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
        .rotationEffect(.degrees(cardRotation))
        .overlay(
            // Confetti overlay
            ZStack {
                if showConfetti {
                    ForEach(0..<20, id: \.self) { index in
                        ConfettiPiece()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showConfetti = false
                                }
                            }
                    }
                }
            }
        )
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
        }
    }
    
    private func triggerConfetti() {
        showConfetti = true
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
}

// MARK: - Confetti Piece
struct ConfettiPiece: View {
    @State private var yOffset: CGFloat = -50
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    
    private let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    private let startX = CGFloat.random(in: -200...200)
    private let endX = CGFloat.random(in: -300...300)
    private let animationDuration = Double.random(in: 2...4)
    
    var body: some View {
        Rectangle()
            .fill(colors.randomElement() ?? .red)
            .frame(width: 8, height: 8)
            .cornerRadius(2)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                xOffset = startX
                
                withAnimation(.easeOut(duration: animationDuration)) {
                    yOffset = 600
                    xOffset = endX
                    rotation = Double.random(in: 0...720)
                }
                
                withAnimation(.easeIn(duration: animationDuration * 0.3).delay(animationDuration * 0.7)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Glowing Gradient Button
struct GlowingGradientButton: View {
    let title: String
    let action: () -> Void
    @State private var isPressed = false
    @State private var glowIntensity: Double = 0.5
    @EnvironmentObject var theme: ThemeManager
    @StateObject private var soundManager = SoundManager()
    
    var body: some View {
        Button(action: {
            if theme.soundEnabled {
                soundManager.playSound("pop")
            }
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            action()
        }) {
            Text(title)
                .font(.system(size: theme.accessibilityLargeText ? 22 : 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        // Base gradient
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.9, green: 0.2, blue: 0.6),
                                Color(red: 0.6, green: 0.2, blue: 0.9),
                                Color(red: 0.2, green: 0.4, blue: 0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Glow overlay
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(glowIntensity * 0.3),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .cornerRadius(25)
                .shadow(
                    color: Color(red: 0.6, green: 0.2, blue: 0.9).opacity(0.6),
                    radius: isPressed ? 8 : 20,
                    x: 0,
                    y: isPressed ? 4 : 10
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowIntensity = 1.0
            }
        }
    }
}

// MARK: - Timeline Graph View
struct TimelineGraphView: View {
    let dailyData: [Date: Int]
    @EnvironmentObject var theme: ThemeManager
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    private var sortedData: [(Date, Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).compactMap { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let count = dailyData[date, default: 0]
            return (date, count)
        }.reversed()
    }
    
    private var maxValue: Int {
        sortedData.map { $0.1 }.max() ?? 1
    }
    
    var body: some View {
        GlassmorphicCard {
            VStack(spacing: 16) {
                Text("📈 7-Day Activity")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(Array(sortedData.enumerated()), id: \.offset) { index, data in
                        let (date, count) = data
                        
                        VStack(spacing: 8) {
                            // Bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.blue.opacity(0.8),
                                            Color.purple.opacity(0.6)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(
                                    width: 24,
                                    height: max(CGFloat(count) / CGFloat(maxValue) * 80, 4)
                                )
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(Double(index) * 0.1), value: count)
                            
                            // Day label
                            Text(dayFormatter.string(from: date))
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(theme.textSecondary)
                        }
                    }
                }
                .frame(height: 100)
            }
        }
    }
}

// MARK: - Custom Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct PremiumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple, Color.pink]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.2),
                            Color.clear
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .blue.opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
