//
//  MediaFSBonjourFinder.swift
//  Muvia
//
//  Created by Alexander Bralnin on 15.04.2025.
//
import Foundation
import Network

@MainActor
class MediaFSBonjourFinder: ObservableObject {
    @Published var resolvedHost: String? = nil

    private var browser: NWBrowser?

    func startSearching() {
        let serviceType = "_http._tcp"
        let serviceDomain = "local."
        let expectedName = "MediaFS"

        let params = NWParameters()
        params.includePeerToPeer = true

        browser = NWBrowser(for: .bonjour(type: serviceType, domain: serviceDomain), using: params)

        browser?.browseResultsChangedHandler = { [weak self] results, _ in
            guard let self = self else { return }

            for result in results {
                if case let .service(name, _, _, _) = result.endpoint, name == expectedName {
                    print("📡 Найден MediaFS!")
                    
                    Task { @MainActor in
                        self.browser?.cancel()
                        self.resolve(endpoint: result.endpoint)
                    }
                    
                    break
                }
            }
        }

        browser?.stateUpdateHandler = { state in
            print("📶 Browser state:", state)
            if case .failed(let error) = state {
                print("❌ Ошибка поиска:", error)
            }
        }

        browser?.start(queue: .main)
        print("🔍 Запущен поиск MediaFS...")
    }

    private func resolve(endpoint: NWEndpoint) {
        let params = NWParameters.tcp
        params.includePeerToPeer = true

        let connection = NWConnection(to: endpoint, using: params)

        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                if let endpoint = connection.currentPath?.remoteEndpoint,
                   case let .hostPort(host, port) = endpoint {

                    let cleanHost = host.debugDescription.removingInterfaceSpecifier()

                    Task { @MainActor in
                        print("✅ MediaFS найден: \(cleanHost):\(port)")
                        self?.resolvedHost = "\(cleanHost):\(port)"
                    }
                }
                connection.cancel()
            case .failed(let error):
                print("❌ Ошибка подключения:", error)
                connection.cancel()
            default:
                break
            }
        }

        connection.start(queue: .main)
    }

    func stopSearching() {
        browser?.cancel()
        browser = nil
    }
}
