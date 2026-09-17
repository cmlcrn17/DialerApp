import SwiftUI

struct ActiveCallView: View {
    @ObservedObject var model: ActiveCallViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.43, green: 0.24, blue: 0.78),
                    Color(red: 0.22, green: 0.38, blue: 0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 20)

                Button(action: model.onEndCall) {
                    Image(systemName: "phone.down.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(.red, in: Circle())
                        .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
                }
                .accessibilityLabel("Aramayı sonlandır")

                Spacer(minLength: 40)

                Circle()
                    .fill(.white.opacity(0.16))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 46))
                            .foregroundStyle(.white)
                    )

                Text(model.contactName ?? model.phoneNumber)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .padding(.top, 22)

                if model.contactName != nil {
                    Text(model.phoneNumber)
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.top, 6)
                }

                Text(model.formattedDuration)
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 6)

                Spacer()

                HStack(spacing: 26) {
                    CallControlButton(
                        systemImage: model.isMuted ? "mic.slash.fill" : "mic.fill",
                        label: "Sessiz",
                        isActive: model.isMuted,
                        action: model.onToggleMute
                    )
                    CallControlButton(
                        systemImage: "pause.fill",
                        label: "Beklet",
                        isActive: model.isOnHold,
                        action: model.onToggleHold
                    )
                    CallControlButton(
                        systemImage: model.isSpeakerOn ? "speaker.wave.3.fill" : "speaker.fill",
                        label: "Hoparlör",
                        isActive: model.isSpeakerOn,
                        action: model.onToggleSpeaker
                    )
                }
                .padding(.bottom, 56)
            }
            .padding(.horizontal, 28)
        }
        .onAppear { model.startTimer() }
        .onDisappear { model.stopTimer() }
    }
}

private struct CallControlButton: View {
    let systemImage: String
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(isActive ? .black : .white)
                    .frame(width: 64, height: 64)
                    .background(
                        isActive ? AnyShapeStyle(.white) : AnyShapeStyle(.white.opacity(0.18)),
                        in: Circle()
                    )
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ActiveCallView(model: ActiveCallViewModel(phoneNumber: "+90 (530) 737 00 83"))
}
