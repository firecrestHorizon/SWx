//
//  firecrestHORIZON.uk
//
//  e-Mail : kieran.conlon@firecresthorizon.uk
//  Twitter: @firecrestHRZN and @Kieran_Conlon
//

import Foundation

extension KpIndexValue: CustomStringConvertible {
  var description: String {
    let scaleString = noaaScale.map { " scale: \"\($0)\"" } ?? ""
		let valueString = String(format: "%5.2f", kp)
		return "\(timeTag) Kp: \(valueString) [\(observed.rawValue)]\(scaleString)"
  }
}

extension KpIndexValue {
  var barLine: String {
    var barChar: String
    switch observed {
    case .estimated:
      barChar = "~"
    case .predicted:
      barChar = "+"
    default:
      barChar = "█"
    }
    return String(repeating: barChar, count: Int(kp * 3))
  }
}

func createKpIndexTextChart(for kpData: KpIndexData) -> String {
  var barLines = [String]()
  var dates = [Date]()
  
  var chartLines = [String]()
  
  for kpDatum in kpData.kpIndexValues {
    barLines.append(kpDatum.barLine)
    dates.append(kpDatum.timeTag)
  }
  
  let maxLength = barLines.map { $0.count }.max() ?? 0
  
  for index in (0..<maxLength).reversed() {
    let scaleLabel = index % 3 == 0 ? String(format: "%2d", index/3) : "  "
    var line = "\(scaleLabel) | "
    for barLine in barLines {
      if index < barLine.count {
        line += String(barLine[barLine.index(barLine.startIndex, offsetBy: index)])
      } else {
        line += " "
      }
    }
    line += " | \(scaleLabel)"
    chartLines.append(line)
  }
  
  // Print the bottom scale with date change indicator
  var scaleLine = "     "
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd"
  let outputDateFormatter = DateFormatter()
  outputDateFormatter.dateFormat = Locale.current.identifier.contains("_US") ? "▏MMM-dd" : "▏dd-MMM"
  var previousDate: String? = nil
  var position = 0

  while position < dates.count {
    let currentDate = dateFormatter.string(from: dates[position])
    if currentDate != previousDate {
      scaleLine += outputDateFormatter.string(from: dates[position])
      position += 7
    } else {
      scaleLine += " "
      position += 1
    }
    previousDate = currentDate
  }
  scaleLine += "     "
  chartLines.append(scaleLine)

  chartLines.append("     Dataset: \(SWxDataSources.planetaryKpIndex.rawValue)")
  
  return chartLines.joined(separator: "\n")
}
