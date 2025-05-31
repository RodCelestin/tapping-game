import SwiftUI

struct LeaderboardEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var playerName: String = ""
    @State private var showLeaderboard = false
    let score: Int
    @Binding var showResult: Bool
    @Binding var showLeaderboardEntry: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("Enter your name", text: $playerName)
                .font(.custom("Omnes SemiBold", size: 24))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                if !playerName.isEmpty {
                    LeaderboardService.saveScore(name: playerName, score: score)
                    showLeaderboard = true
                }
            }) {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Validate")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: "009DE0"))
                        .frame(maxWidth: .infinity, alignment: .top)
                    Spacer()
                }
            }
            
            .buttonStyle(CustomPressableButtonStyle())
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("BlueBackground")
                .resizable()
                .ignoresSafeArea()
        )
        .onAppear {
            // Show keyboard immediately
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .fullScreenCover(isPresented: $showLeaderboard) {
            LeaderboardView(showResult: $showResult, showLeaderboardEntry: $showLeaderboardEntry)
        }
    }
}

#Preview {
    LeaderboardEntryView(score: 42, showResult: .constant(true), showLeaderboardEntry: .constant(true))
} 
