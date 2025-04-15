import SwiftUI

struct VideoListView: View {
    let host: String
    @StateObject private var viewModel: VideoListViewModel
    @State private var selectedFile: MediaFile?

    init(host: String) {
        self.host = host
        _viewModel = StateObject(wrappedValue: VideoListViewModel(host: host))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Muvia Library")
                .task { await viewModel.fetchFiles() }
                .fullScreenCover(item: $selectedFile) { file in
                    VideoPlayerView(
                        url: viewModel.videoURL(for: file),
                        token: viewModel.tokenHeader()
                    )
                }
        }
    }
}

// MARK: - View Composition

private extension VideoListView {
    @ViewBuilder
    var content: some View {
        VStack(spacing: 0) {
            fileList
            errorView
        }
    }

    var fileList: some View {
        List(viewModel.files) { file in
            Button(file.name) {
                selectedFile = file
            }
        }
    }

    @ViewBuilder
    var errorView: some View {
        if let error = viewModel.errorMessage {
            InlineErrorView(message: error)
        }
    }
}
