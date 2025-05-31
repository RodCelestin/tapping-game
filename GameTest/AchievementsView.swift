import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var achievementService: AchievementService // Access the achievement service
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Achievements")
                .font(.custom("Omnes SemiBold", size: 36))
                .foregroundColor(.white)
                .padding(.top, 40)
                .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(achievementService.getAchievements()) { achievement in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(achievement.name)
                                .font(.custom("Omnes SemiBold", size: 24))
                                .foregroundColor(.white)
                            
                            Text(achievement.description)
                                .font(.custom("Omnes SemiBold", size: 16))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Image(systemName: achievement.isUnlocked ? "lock.open.fill" : "lock.fill")
                                    .foregroundColor(achievement.isUnlocked ? .green : .red)
                                Text(achievement.isUnlocked ? "Unlocked" : "Locked")
                                    .font(.custom("Omnes SemiBold", size: 16))
                                    .foregroundColor(achievement.isUnlocked ? .green : .red)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
            Button(action: {
                dismiss()
            }) {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Close")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("BlueBackground")
                .resizable()
                .ignoresSafeArea()
        )
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AchievementService())
} 