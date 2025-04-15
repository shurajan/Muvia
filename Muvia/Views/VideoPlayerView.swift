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
            if let player = viewModel.player {
                VideoPlayer(player: player)
                    .onTapGesture {
                        withAnimation { viewModel.showCloseButton = true }
                        viewModel.scheduleAutoHide()
                    }
                    .ignoresSafeArea()
            } else {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .ignoresSafeArea()
            }

            if viewModel.showCloseButton {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .transition(.opacity)
                .padding()
            }

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
        .offset(x: dragOffset.width, y: dragOffset.height)
        .background(Color.black)
        .gesture(
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
        )
    }
}
