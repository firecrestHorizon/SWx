//
//  firecrestHORIZON.uk
//  🦋 @kieran.firecresthorizon.uk
//

import Foundation

func createKpIndexTextReport(for kpData: KpIndexData) -> String {
  let maxObservedKp = kpData.kpIndexValues
    .filter { $0.observed == .observed }
    .max()?.kp ?? 0

  let maxForecastKp = kpData.kpIndexValues
    .filter { $0.observed != .observed }
    .max()?.kp ?? 0

  let reportLines = kpData.kpIndexValues.map { kpIndexValue -> String in
    let maxMarker = (kpIndexValue.observed == .observed && kpIndexValue.kp >= maxObservedKp) ||
      (kpIndexValue.observed != .observed && kpIndexValue.kp >= maxForecastKp) ? " *" : ""
    return "\(kpIndexValue)\(maxMarker)"
  }

  return reportLines.joined(separator: "\n")
}
