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
    
    mutating func run() async throws {
      let kpData = try await downloadKpIndexForecast()
      
      print(createKpIndexTextChart(for: kpData))
    }
  }
}
