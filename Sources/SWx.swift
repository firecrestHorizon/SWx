// Kieran Conlon
// Copyright © 2023 firecrestHORIZON.uk.  All rights reserved.
//

import Foundation
import ArgumentParser

@main
struct SWx: AsyncParsableCommand {
  
  static var configuration = CommandConfiguration(
    abstract: "NOAA Space Weather Data Retreival",
    subcommands: [KpForecast.self],
    defaultSubcommand: KpForecast.self
  )
  
}

extension SWx {
  struct KpForecast: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
      abstract: "Retreive Kp forecast"
    )

		@Flag(name: [.short, .long], help: "Display as text.")
		var textOutput: Bool = false

		mutating func run() async throws {
			let kpData = try await downloadKpIndexForecast()

			if textOutput {
				print(createKpIndexTextReport(for: kpData))
			} else {
				print(createKpIndexTextChart(for: kpData))
			}
		}
  }
}
