import SwiftUI

struct LeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var entries: [LeaderboardEntry] = []
    @Binding var showResult: Bool
    @Binding var showLeaderboardEntry: Bool
    @State private var stickyHeaderOpacity: Double = 0
    @State private var debugScrollOffset: CGFloat = 0 // State to hold the raw scroll offset for debugging
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ScrollView {
                    // Use a GeometryReader at the very top of the scrollable content to get overall scroll position
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("scrollView")).minY
                        )
                    }
                    .frame(height: 0) // Make the GeometryReader invisible and not take space
                    
                    VStack(spacing: 20) {
                        // Main title
                        Text("Leaderboard")
                            .font(.custom("Omnes SemiBold", size: 36))
                            .foregroundColor(.white)
                            .padding(.top, 40)
                        
                        VStack(spacing: 12) {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(.custom("Omnes SemiBold", size: 24))
                                        .foregroundColor(.white)
                                        .frame(width: 40)
                                    
                                    Text(entry.name)
                                        .font(.custom("Omnes SemiBold", size: 24))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(entry.score)")
                                        .font(.custom("Omnes SemiBold", size: 24))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .coordinateSpace(name: "scrollView")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    debugScrollOffset = value // Update debug state
                    
                    // Calculate opacity based on scroll position
                    // value is the minY of the top of the scrollable content (negative of scroll offset)
                    // We want opacity to go from 0 to 1 as value goes from 0 down to -100
                    let scrollOffset = -value // Convert minY to a positive scroll offset
                    let fadeStartOffset: CGFloat = 0 // Start fading when scrolled 0px
                    let fadeEndOffset: CGFloat = 100 // Fully faded when scrolled 100px
                    
                    let scrollDistance = scrollOffset - fadeStartOffset
                    let fadeRange = fadeEndOffset - fadeStartOffset
                    
                    let progress = min(max(0, scrollDistance / fadeRange), 1)
                    stickyHeaderOpacity = progress
                }
                
                Button(action: {
                    showResult = false
                    showLeaderboardEntry = false
                    dismiss()
                }) {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("Back to game")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex: "009DE0"))
                            .frame(maxWidth: .infinity, alignment: .top)
                        Spacer()
                    }
                }
                .buttonStyle(CustomPressableButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
            // Sticky header
            Text("Leaderboard")
                .font(.custom("Omnes SemiBold", size: 24))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.top)
                )
                .opacity(stickyHeaderOpacity)
                .animation(.easeInOut(duration: 0.1), value: stickyHeaderOpacity) // Smoother animation
            
            // Debug Text to show scroll offset
            Text("Scroll Offset: \(debugScrollOffset)")
                .foregroundColor(.white)
                .padding(.top, 60) // Position it below the sticky header area
                .opacity(debugScrollOffset < 0 ? 1 : 0) // Only show when scrolled down
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("BlueBackground")
                .resizable().ignoresSafeArea()
        )
        .onAppear {
            entries = LeaderboardService.getLeaderboard()
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    LeaderboardView(showResult: .constant(true), showLeaderboardEntry: .constant(true))
} 