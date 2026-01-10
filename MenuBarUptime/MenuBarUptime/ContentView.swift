import SwiftUI
import AppKit
import Combine

struct ContentView: View {

    @State private var uptime = UptimeFormatter.format()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 12) {
            Text("Mac Uptime")
                .font(.headline)

            Text(uptime)
                .font(.system(size: 26, weight: .bold, design: .monospaced))

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(14)
        .frame(minWidth: 190)
        .onReceive(timer) { _ in
            uptime = UptimeFormatter.format()
        }
    }
}

