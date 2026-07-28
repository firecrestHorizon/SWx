// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation
import ArgumentParser
import Darwin

enum TerminalColorMode: String, CaseIterable, ExpressibleByArgument {
  case auto
  case always
  case never

  func shouldUseColor(isTerminal: Bool, environment: [String: String]) -> Bool {
    switch self {
    case .always:
      return true
    case .never:
      return false
    case .auto:
      guard isTerminal else { return false }
      guard environment["NO_COLOR"] == nil else { return false }
      guard environment["TERM"]?.lowercased() != "dumb" else { return false }

      let isXcodeConsole = environment["__XCODE_BUILT_PRODUCTS_DIR_PATHS"] != nil ||
        environment["OS_ACTIVITY_DT_MODE"] == "YES" ||
        environment["XPC_SERVICE_NAME"]?.contains("com.apple.dt.Xcode") == true
      return !isXcodeConsole
    }
  }
}

enum OutputFormat: String, CaseIterable, ExpressibleByArgument {
  case text
  case json
  case csv
}

@main
struct SWx: AsyncParsableCommand {
  
  static var configuration = CommandConfiguration(
    abstract: "NOAA Space Weather Data Retrieval",
    subcommands: [KpForecast.self],
    defaultSubcommand: KpForecast.self
  )
  
}

extension SWx {
  struct KpForecast: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Retrieve Kp forecast"
    )

    @Option(help: "Display a non-chart output: text, json, or csv.")
    var format: OutputFormat?

    @Flag(help: "Display the full Kp 0–9 and G1–G5 scales.")
    var fullScale: Bool = false

    @Option(help: "Colour output: auto, always, or never.")
    var color: TerminalColorMode = .auto

    mutating func validate() throws {
      if format != nil && fullScale {
        throw ValidationError("--full-scale can only be used with the default chart output.")
      }
    }

    mutating func run() async throws {
      let kpData = try await downloadKpIndexForecast()

      switch format {
      case .text:
        print(createKpIndexTextReport(for: kpData))

      case .json:
        print(try createKpIndexJSONReport(for: kpData))

      case .csv:
        print(createKpIndexCSVReport(for: kpData))

      case nil:
        let useColor = color.shouldUseColor(
          isTerminal: isatty(STDOUT_FILENO) != 0,
          environment: ProcessInfo.processInfo.environment
        )
        print(
          createKpIndexTextChart(
            for: kpData,
            fullScale: fullScale,
            useColor: useColor
          )
        )
      }
    }
  }
}
