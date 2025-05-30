//
//  ContentView.swift
//  GameTest
//
//  Created by Rodolphe Celestin on 2025-05-30.
//

import SwiftUI
import Foundation

// Define a struct to represent an individual shockwave
struct Shockwave: Identifiable {
    let id = UUID()
    var scale: CGFloat = 0.1
    var opacity: Double = 0.2
}

struct ContentView: View {
    @State private var tapCount = 0
    @State private var timeRemaining: Double = 15.0
    @State private var isGameActive = false
    @State private var timer: Timer?
    @State private var showResult = false
    @State private var tapBounceScale: CGFloat = 1.0 // Scale for tap bounce effect
    @State private var isShapePressed = false // Track if the shape is being pressed
    @State private var pressScale: CGFloat = 1.0 // Scale for press and hold effect
    @State private var offset: CGSize = .zero
    @State private var floatingOffset: CGFloat = 0
    @State private var initialOffset: CGFloat = 40
    @State private var initialOpacity: Double = 0
    
    // State variable to hold multiple shockwaves
    @State private var shockwaves: [Shockwave] = []
    
    // State variable to hold the dynamic message
    @State private var dynamicMessage: String = ""
    
    // Computed property for the circle color based on tap count
    private var circleColor: Color {
        let maxColorTaps = 100.0 // Taps needed to reach full color intensity
        let colorFactor = min(Double(tapCount) / maxColorTaps, 1.0)
        // Interpolate between white and a target color (e.g., red)
        return Color.white.blend(with: .red, factor: colorFactor)
    }
    
    // Computed property to format the time remaining
    private var formattedTime: String {
        let seconds = Int(timeRemaining)
        // Calculate centiseconds (hundredths of a second)
        let milliseconds = Int((timeRemaining.truncatingRemainder(dividingBy: 1) * 100).rounded())
        return String(format: "%02d:%02d", seconds, milliseconds)
    }
    
    var body: some View {
        VStack {
            if isGameActive {
                Text("\(formattedTime)")
                    .font(.custom("Omnes SemiBold", size: 24))
                    .padding()
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // This VStack groups the dynamic message and the shape/game over content
            VStack(spacing: 20) {
                // Display the dynamic message only when the game is active
                if !showResult {
                    Text(dynamicMessage)
                        .font(.custom("Omnes SemiBold", size: 36).bold())
                        .foregroundColor(.white)
                        .padding()
                        .opacity(dynamicMessage.isEmpty ? 0 : 1)
                        .animation(.easeOut(duration: 0.2), value: dynamicMessage)
                }
                
                if showResult {
                    VStack(spacing: 20) {
                        Text("Time's up!")
                            .font(.custom("Omnes SemiBold", size: 28))
                            .foregroundColor(.white)
                            .padding(.top, 40)
                        
                        Spacer()
                            .frame(height: 60)
                        
                        Text("\(tapCount)")
                            .font(.custom("Omnes SemiBold", size: 86).bold())
                            .foregroundColor(.white)
                        
                        Text("Not to bad!")
                            .font(.custom("Omnes SemiBold", size: 28))
                            .foregroundColor(.white)
                            .padding(.top, -10)
                        
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 100, height: 100)
                        .scaleEffect(tapBounceScale * pressScale)
                        .offset(x: offset.width, y: offset.height + floatingOffset + initialOffset)
                        .opacity(initialOpacity)
                        .overlay(
                            ZStack {
                                ForEach(shockwaves) {
                                    shockwave in
                                    Circle()
                                        .stroke(Color.white.opacity(shockwave.opacity), lineWidth: 4)
                                        .scaleEffect(shockwave.scale)
                                }
                            }
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    // Start game on first press
                                    if !isGameActive {
                                        startGame()
                                    }
                                    // Scale down on press
                                    if !isShapePressed {
                                        isShapePressed = true
                                        withAnimation(.easeOut(duration: 0.1)) {
                                            pressScale = 0.8
                                        }
                                    }
                                }
                                .onEnded { value in
                                    // Scale back up on release
                                    withAnimation(.easeOut(duration: 0.1)) {
                                        pressScale = 1.0
                                    }
                                    isShapePressed = false
                                    
                                    // Consider it a tap if the drag distance was small
                                    let tapThreshold: CGFloat = 10 // Define a small threshold for tap detection
                                    if value.translation.width.magnitude < tapThreshold && value.translation.height.magnitude < tapThreshold {
                                        tapCount += 1
                                        animateTap()
                                        addShockwave()
                                        updateDynamicMessage()
                                    }
                                }
                        )
                        .onAppear {
                            // Initial appearance animation
                            withAnimation(.easeOut(duration: 0.6)) {
                                initialOffset = 0
                                initialOpacity = 1
                            }
                            
                            // Start floating animation after fade-in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                    floatingOffset = -25
                                }
                            }
                        }
                }
            }
            
            Spacer()
            
            if isGameActive {
                Text("\(tapCount)")
                    .font(.custom("Omnes SemiBold", size: 24))
                    .padding()
                    .foregroundColor(.white)
            }
            
            if showResult {
                Button(action: restartGame) {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("Start again")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex: "009DE0"))
                            .frame(maxWidth: .infinity, alignment: .top)
                        Spacer()
                    }
                }
                .buttonStyle(CustomPressableButtonStyle())
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("BlueBackground")
                .resizable()
                .ignoresSafeArea()
        )
    }
    
    private func animateTap() {
        // Random direction for the bounce
        let randomAngle = Double.random(in: 0..<2 * .pi)
        let randomDistance = CGFloat.random(in: 5...15)
        let randomOffset = CGSize(
            width: CGFloat(Foundation.cos(randomAngle)) * randomDistance,
            height: CGFloat(Foundation.sin(randomAngle)) * randomDistance
        )
        
        // Scale down and move
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            tapBounceScale = 0.8
            offset = randomOffset
        }
        
        // Scale back up and return to center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                tapBounceScale = 1.0
                offset = .zero
            }
        }
    }
    
    private func addShockwave() {
        var newShockwave = Shockwave()
        shockwaves.append(newShockwave)
        
        // Animate the last added shockwave
        let animationDuration = 1.0
        withAnimation(.easeOut(duration: animationDuration)) {
            // Find the index of the shockwave we just added (could be more robust)
            if let index = shockwaves.firstIndex(where: { $0.id == newShockwave.id }) {
                shockwaves[index].scale = 4.0 // Grow larger
                shockwaves[index].opacity = 0.0 // Fade out
            }
        }
        
        // Remove the shockwave after the animation is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            shockwaves.removeAll(where: { $0.id == newShockwave.id })
        }
    }
    
    private func updateDynamicMessage() {
        switch tapCount {
            case 10: dynamicMessage = "Good"
            case 30: dynamicMessage = "Harder!"
            case 50: dynamicMessage = "Crush it!!!"
            case 70: dynamicMessage = "MORE!!!"
            default: break // Keep the current message or do nothing
        }
    }
    
    private func startGame() {
        isGameActive = true
        showResult = false
        tapCount = 0
        timeRemaining = 15.0
        tapBounceScale = 1.0
        pressScale = 1.0
        offset = .zero
        shockwaves = [] // Clear shockwaves on start game
        dynamicMessage = "" // Clear message on start game
        
        // Start floating animation
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            floatingOffset = -8
        }
        
        // Set timer interval to update more frequently
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.01 // Decrement by the interval
                // Ensure time doesn't go below zero visually
                if timeRemaining < 0 { timeRemaining = 0 }
            } else {
                endGame()
            }
        }
    }
    
    private func endGame() {
        timer?.invalidate()
        timer = nil
        isGameActive = false
        showResult = true
        shockwaves = [] // Clear shockwaves on end game
        dynamicMessage = "" // Clear message on end game
    }
    
    private func restartGame() {
        // Reset state to show only the shape and not be active
        isGameActive = false
        showResult = false
        tapCount = 0
        timeRemaining = 15.0 // Reset time visually, but timer isn't running yet
        tapBounceScale = 1.0
        pressScale = 1.0
        offset = .zero
        shockwaves = []
        dynamicMessage = ""
        
        // Reset initial animation states
        initialOffset = 40
        initialOpacity = 0
        
        // Trigger initial appearance animation
        withAnimation(.easeOut(duration: 0.6)) {
            initialOffset = 0
            initialOpacity = 1
        }
        
        // Start floating animation after fade-in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                floatingOffset = -25
            }
        }
        
        // The timer will be started by the onTapGesture on the Circle
    }
}

extension Color {
    // Helper function to blend colors
    func blend(with other: Color, factor: Double) -> Color {
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
        
        UIColor(self).getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        UIColor(other).getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return Color(red: r1 + (r2 - r1) * factor, 
                     green: g1 + (g2 - g1) * factor, 
                     blue: b1 + (b2 - b1) * factor, 
                     opacity: a1 + (a2 - a1) * factor)
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Define a custom button style to control the pressed state
struct CustomPressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label // This is the HStack with "Start again" text
            // Apply the existing styling here, and modify for pressed state
            .padding(.vertical, 0)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            // For example, change background or shadow based on the pressed state
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 8)
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 0)
            // Apply opacity and scale changes based on pressed state
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
