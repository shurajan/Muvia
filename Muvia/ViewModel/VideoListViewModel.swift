import Foundation

@MainActor
class VideoListViewModel: ObservableObject {
    @Published var files: [MediaFile] = []
    @Published var errorMessage: String? = nil

    private let baseURL: URL
    private let token = "supersecret"

    init(host: String) {
        self.baseURL = URL(string: "http://\(host)")!
    }

    func fetchFiles() async {
        errorMessage = nil

        var request = URLRequest(url: baseURL.appendingPathComponent("files"))
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            self.files = try JSONDecoder().decode([MediaFile].self, from: data)
        } catch {
            errorMessage = "Failed to load files: \(error.localizedDescription)"
        }
    }

    func videoURL(for file: MediaFile) -> URL {
        baseURL.appendingPathComponent("files").appendingPathComponent(file.name)
    }

    func tokenHeader() -> String {
        "Bearer \(token)"
    }
}
