import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: VideoPlayerViewModel
    @State private var dragOffset: CGSize = .zero

    init(url: URL, token: String) {
        _viewModel = StateObject(wrappedValue: VideoPlayerViewModel(url: url, token: token))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            playerLayer
            closeButton
            errorOverlay
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                withAnimation { viewModel.showCloseButton = true }
                viewModel.scheduleAutoHide()
            }
        )
        .offset(x: dragOffset.width, y: dragOffset.height)
        .background(Color.black)
        .gesture(dragToDismissGesture)
    }
}

// MARK: - View Components

private extension VideoPlayerView {
    var playerLayer: some View {
        Group {
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .ignoresSafeArea()
            }
        }
    }

    var closeButton: some View {
        Group {
            if viewModel.showCloseButton {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .contentShape(Circle())
                .buttonStyle(.plain)
                .transition(.opacity)
                .padding()
            }
        }
    }

    var errorOverlay: some View {
        Group {
            if let error = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text("❌ \(error)")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.bottom)
                }
            }
        }
    }

    var dragToDismissGesture: some Gesture {
        DragGesture()
            .onChanged { dragOffset = $0.translation }
            .onEnded { value in
                let threshold: CGFloat = 100
                if abs(value.translation.width) > threshold || abs(value.translation.height) > threshold {
                    dismiss()
                } else {
                    withAnimation { dragOffset = .zero }
                }
            }
    }
}
