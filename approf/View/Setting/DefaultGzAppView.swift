// Created for approf in 2024

import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct DefaultGzAppView: View {
  @State private var defaultApp: GzApp = .dummy
  @State var apps: [GzApp] = []

  var body: some View {
    GridRow {
      Text("Open `.pb.gz` with").gridColumnAlignment(.trailing)
      // Neither image.frame() nor VStack{Text() Text()} works in Picker
      Picker("", selection: $defaultApp) {
        ForEach(apps, id: \.self) { app in
          HStack(alignment: .center) {
            Image(nsImage: app.icon.resize(withSize: .init(width: 18, height: 18)))
            if app.hasDupName {
              Text(app.name) + Text("\n") +
                Text(app.url.nicePath).foregroundStyle(.secondary).font(.footnote)
            } else {
              Text(app.name)
            }
          }
        }
      }
      .pickerStyle(.automatic)
      .labelsHidden()
    }
    .onAppear {
      guard let url = Bundle.main.url(forResource: "test-default-app.pb", withExtension: "gz") else {
        log.error("test-default-app.pb.gz not found")
        return
      }
      self.loadApps(for: url)
      self.loadDefaultApp(for: url)
    }
    .onChange(of: defaultApp) { old, neu in
      if old != .dummy && neu != .dummy {
        log.info("setting \(neu.url) as default app for .gz")
        NSWorkspace.shared.setDefaultApplication(at: neu.url, toOpen: UTType.gzip) { err in
          if let err = err {
            log.error("NSWorkspace.shared.setDefaultApplication error: \(err)")
          }
        }
      }
    }
  }

  func loadApps(for url: URL) {
    let appURLs = NSWorkspace.shared.urlsForApplications(toOpen: url)
    var loadedApps: [GzApp] = []
    var names: [String] = []

    for appURL in appURLs {
      let appName = appURL.lastPathComponent
      let icon = NSWorkspace.shared.icon(forFile: appURL.path)
      loadedApps.append(GzApp(name: appName, url: appURL, icon: icon, hasDupName: false))
      names.append(appName)
    }

    if names.count == Set(names).count {
      apps = loadedApps
    } else {
      // some apps hav the same name
      var newApps: [GzApp] = []
      for app in loadedApps {
        let hasDupName = names.count(where: { $0 == app.name }) > 1
        newApps.append(.init(name: app.name, url: app.url, icon: app.icon, hasDupName: hasDupName))
      }
      apps = newApps
    }
  }

  func loadDefaultApp(for url: URL) {
    let url = NSWorkspace.shared.urlForApplication(toOpen: url)
    if let url = url {
      let appName = url.lastPathComponent
      let icon = NSWorkspace.shared.icon(forFile: url.path)
      defaultApp = GzApp(name: appName, url: url, icon: icon, hasDupName: false)
    }
  }

  struct GzApp: Identifiable, Hashable {
    var id: String {
      url.absoluteString
    }

    let name: String
    let url: URL
    let icon: NSImage
    let hasDupName: Bool

    func hash(into hasher: inout Hasher) {
      hasher.combine(url)
    }

    static func == (lhs: GzApp, rhs: GzApp) -> Bool {
      return lhs.url == rhs.url
    }

    static var dummy = GzApp(name: "", url: URL(fileURLWithPath: ""), icon: .init(), hasDupName: false)
  }
}
