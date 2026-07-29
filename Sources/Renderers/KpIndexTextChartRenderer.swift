//
// KpIndexTextChartRenderer.swift
// SWx
//
//  🦋 @kieran.firecresthorizon.uk
//  firecrestHORIZON.uk
//

import Foundation

extension KpIndexValue: CustomStringConvertible {
  var description: String {
    let scaleString = noaaScale.map { " scale: \"\($0)\"" } ?? ""
    let valueString = String(format: "%5.2f", kp)
    return "\(timeTag) Kp: \(valueString) [\(observed.rawValue)]\(scaleString)"
  }
}

extension KpObservationType {
  func barCharacter(useColor: Bool) -> String {
    guard useColor else {
      switch self {
      case .observed:
        return "█"
      case .estimated:
        return "▓"
      case .predicted:
        return "░"
      }
    }

    let foregroundColor: String
    switch self {
    case .estimated:
      foregroundColor = "\u{001B}[37m"
    case .predicted:
      foregroundColor = "\u{001B}[90m"
    default:
      foregroundColor = "\u{001B}[97m"
    }
    return "\(foregroundColor)█\u{001B}[39m"
  }
}

extension KpIndexValue {
  var barLine: String {
    return String(repeating: "█", count: max(0, Int((kp * 3).rounded())))
  }
}

private func chartLegend(useColor: Bool) -> String {
  let observed = KpObservationType.observed.barCharacter(useColor: useColor)
  let estimated = KpObservationType.estimated.barCharacter(useColor: useColor)
  let predicted = KpObservationType.predicted.barCharacter(useColor: useColor)
  return "     Data: \(observed) Observed  \(estimated) Estimated  \(predicted) Predicted"
}

private func latestObservedDescription(for kpData: KpIndexData) -> String {
  guard let latestObservedDate = kpData.kpIndexValues
    .filter({ $0.observed == .observed })
    .map(\.timeTag)
    .max()
  else {
    return "unavailable"
  }

  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.dateFormat = "yyyy-MM-dd HH:mm 'UTC'"
  return formatter.string(from: latestObservedDate)
}

private func geomagneticStormLevel(for kp: Int) -> String? {
  guard (5...9).contains(kp) else { return nil }
  return "G\(kp - 4)"
}

private func geomagneticStormColor(for kp: Int) -> String? {
  switch kp {
  case 5, 6:
    return "\u{001B}[38;2;64;255;0m"
  case 7:
    return "\u{001B}[38;2;247;254;46m"
  case 8:
    return "\u{001B}[38;2;240;104;0m"
  case 9:
    return "\u{001B}[38;2;255;0;0m"
  default:
    return nil
  }
}

private func bgsActivityColor(for scaleIndex: Int) -> String {
  switch scaleIndex {
  case ...9:
    return "\u{001B}[38;2;4;49;180m"
  case 10...13:
    return "\u{001B}[38;2;0;204;255m"
  case 14...19:
    return "\u{001B}[38;2;64;255;0m"
  case 20...22:
    return "\u{001B}[38;2;247;254;46m"
  case 23...26:
    return "\u{001B}[38;2;240;104;0m"
  default:
    return "\u{001B}[38;2;255;0;0m"
  }
}

func createKpIndexTextChart(
  for kpData: KpIndexData,
  fullScale: Bool = false,
  useColor: Bool = false
) -> String {
  var barLines = [String]()
  var dates = [Date]()
  
  var chartLines = [String]()
  
  for kpDatum in kpData.kpIndexValues {
    barLines.append(kpDatum.barLine)
    dates.append(kpDatum.timeTag)
  }
  
  let dataMaxLength = barLines.map { $0.count }.max() ?? 0
  let maxLength = fullScale ? 9 * 3 : dataMaxLength

  let activityScaleWidth = useColor ? 1 : 0
  chartLines.append(
    " Kp " + String(repeating: " ", count: barLines.count + 4 + activityScaleWidth) + "G Scale"
  )

  if maxLength > 0 {
    let topIndex = maxLength % 3 == 0 ? maxLength : maxLength - 1

    for index in stride(from: topIndex, through: 0, by: -1) {
      let isScaleTick = index > 0 && index % 3 == 0
      let kpScaleValue = index / 3
      let scaleLabel = isScaleTick ? String(format: "%2d", kpScaleValue) : "  "
      let stormLevel = isScaleTick ? geomagneticStormLevel(for: kpScaleValue) : nil
      let leftAxis = isScaleTick ? "┤" : "│"
      var line = "\(scaleLabel) \(leftAxis) "
      for (barIndex, barLine) in barLines.enumerated() {
        if index < barLine.count {
          line += kpData.kpIndexValues[barIndex].observed.barCharacter(useColor: useColor)
        } else {
          line += " "
        }
      }
      if useColor {
        line += " \(bgsActivityColor(for: index))█\u{001B}[39m"
      } else {
        line += " "
      }
      if let stormLevel {
        if useColor, let stormColor = geomagneticStormColor(for: kpScaleValue) {
          line += "├ \(stormColor)\(stormLevel)\u{001B}[39m"
        } else {
          line += "├ \(stormLevel)"
        }
      } else {
        line += "│"
      }
      chartLines.append(line)
    }
  }

  let baseline = " 0 └" + String(
    repeating: "─",
    count: barLines.count + 2 + activityScaleWidth
  ) + "┘"
  chartLines.append(baseline)
  
  // Print the bottom scale with date change indicator
  var scaleLine = "     "
  let dateFormatter = DateFormatter()
  dateFormatter.locale = Locale(identifier: "en_US_POSIX")
  dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
  dateFormatter.dateFormat = "yyyy-MM-dd"

  let outputDateFormatter = DateFormatter()
  outputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
  outputDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
  outputDateFormatter.dateFormat = Locale.current.regionCode == "US" ? "▏MMM-dd" : "▏dd-MMM"
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

  chartLines.append(chartLegend(useColor: useColor))
  chartLines.append("     Dataset: \(SWxDataSources.planetaryKpIndex.rawValue)")
  chartLines.append("     Latest observed: \(latestObservedDescription(for: kpData))")
  
  return chartLines.joined(separator: "\n")
}
