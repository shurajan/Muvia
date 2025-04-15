import SwiftUI

@main
struct MuviaApp: App {
    @StateObject var finder = MediaFSBonjourFinder()
    @State private var fallbackTriggered = false
    @State private var manualHost: String = "localhost"
    @State private var manualPort: String = "8000"

    var body: some Scene {
        WindowGroup {
            content
                .preferredColorScheme(nil)
        }
    }
}

// MARK: - View Composition

private extension MuviaApp {
    @ViewBuilder
    var content: some View {
        if let host = finder.resolvedHost {
            VideoListView(host: host)
        } else if fallbackTriggered {
            manualInputView
        } else {
            searchProgressView
        }
    }

    var manualInputView: some View {
        VStack(spacing: 20) {
            Text("Server not found")
                .font(.headline)

            TextField("IP Address", text: $manualHost)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 250)

            TextField("Port", text: $manualPort)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 250)

            Button("Connect") {
                finder.resolvedHost = "\(manualHost):\(manualPort)"
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    var searchProgressView: some View {
        ProgressView("Searching for MediaFS…")
            .task {
                finder.startSearching()

                try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                if finder.resolvedHost == nil {
                    fallbackTriggered = true
                    print("⚠️ Bonjour fallback: manual input required")
                }
            }
    }
}
