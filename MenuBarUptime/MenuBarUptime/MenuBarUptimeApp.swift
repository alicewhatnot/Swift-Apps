//
//  MenuBarUptimeApp.swift
//  MenuBarUptime
//
//  Created by Michael Gillbanks on 10/01/2026.
//

import SwiftUI
import Combine
import AppKit
import ServiceManagement

@main
struct MenuBarUptimeApp: App {

    @State private var menuLabel = UptimeFormatter.format()

    let menuTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init() {
        do {
            try SMAppService.mainApp.register()
        } catch {
            // Registration can fail if not properly configured in Signing & Capabilities
            // or when running in development without a helper. Ignore failure for now.
            // You may want to log this error or surface it in a debug build.
            #if DEBUG
            print("SMAppService registration failed: \(error)")
            #endif
        }
    }

    var body: some Scene {
        MenuBarExtra {
            UptimeMenuContentView()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "clock")      // black & white clock
                Text(menuLabel)
                    .monospacedDigit()
            }
            .onReceive(menuTimer) { _ in
                menuLabel = UptimeFormatter.format()
            }
        }
    }
}

struct UptimeMenuContentView: View {

    @State private var uptimeText = UptimeFormatter.format()
    let uptimeTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 12) {

            Text("Mac Uptime")
                .font(.headline)

            Text(uptimeText)
                .font(.system(size: 26, weight: .bold, design: .monospaced))

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(14)
        .frame(minWidth: 190)
        .onReceive(uptimeTimer) { _ in
            uptimeText = UptimeFormatter.format()
        }
    }
}

struct UptimeFormatter {

    static func format() -> String {
        var boottime = timeval()
        var size = MemoryLayout<timeval>.stride
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]

        // sysctl returns 0 on success
        guard sysctl(&mib, UInt32(mib.count), &boottime, &size, nil, 0) == 0 else {
            return "??:??:??:??"
        }

        let bootDate = Date(timeIntervalSince1970: TimeInterval(boottime.tv_sec))
        let interval = Date().timeIntervalSince(bootDate)

        let seconds = Int(interval)
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        return String(format: "%02d:%02d:%02d:%02d", days, hours, minutes, secs)
    }
}
