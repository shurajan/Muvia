import SwiftUI

@main
struct MuviaApp: App {
    @StateObject var finder = MediaFSBonjourFinder()
    @State private var fallbackTriggered = false
    @State private var manualHost: String = "localhost"
    @State private var manualPort: String = "8000"

    var body: some Scene {
        WindowGroup {
            Group {
                if let host = finder.resolvedHost {
                    VideoListView(host: host)
                } else if fallbackTriggered {
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
                } else {
                    ProgressView("Searching for MediaFS…")
                        .task {
                            finder.startSearching()

                            // fallback через 5 секунд на ручной ввод
                            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                            if finder.resolvedHost == nil {
                                fallbackTriggered = true
                                print("⚠️ Bonjour fallback: manual input required")
                            }
                        }
                }
            }
            .preferredColorScheme(nil)
        }
    }
}
