//
//  firecrestHORIZON.uk
//  🦋 @kieran.firecresthorizon.uk
//

import Foundation

private let observedPeakMarker = "◆"
private let forecastPeakMarker = "◇"

private var utcCalendar: Calendar {
  var calendar = Calendar(identifier: .gregorian)
  calendar.timeZone = TimeZone(secondsFromGMT: 0)!
  return calendar
}

private let reportDateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.dateFormat = "EEE dd MMM"
  return formatter
}()

private let reportTimeFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.locale = Locale(identifier: "en_US_POSIX")
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  formatter.dateFormat = "HH:mm"
  return formatter
}()

private let iso8601Formatter: ISO8601DateFormatter = {
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions = [.withInternetDateTime]
  formatter.timeZone = TimeZone(secondsFromGMT: 0)
  return formatter
}()

private func sortedValues(in kpData: KpIndexData) -> [KpIndexValue] {
  kpData.kpIndexValues.sorted { $0.timeTag < $1.timeTag }
}

private func padded(_ value: String, to width: Int) -> String {
  value + String(repeating: " ", count: max(0, width - value.count))
}

func createKpIndexTextReport(for kpData: KpIndexData) -> String {
  let values = sortedValues(in: kpData)
  let maxObservedKp = values
    .filter { $0.observed == .observed }
    .max()?.kp ?? 0

  let maxForecastKp = values
    .filter { $0.observed != .observed }
    .max()?.kp ?? 0

  var lines = [
    "Planetary Kp forecast · UTC",
    "",
    "Date         Time   Kp    Type         G    Trend",
  ]
  var previousValue: KpIndexValue?
  var previousDate: Date?
  var forecastDividerAdded = false

  for value in values {
    if value.observed != .observed && !forecastDividerAdded {
      lines.append("")
      lines.append("-------------------- FORECAST --------------------")
      lines.append("")
      forecastDividerAdded = true
    }

    let showDate = previousDate.map {
      !utcCalendar.isDate($0, inSameDayAs: value.timeTag)
    } ?? true
    let date = showDate ? reportDateFormatter.string(from: value.timeTag) : ""
    let time = reportTimeFormatter.string(from: value.timeTag)
    let kp = String(format: "%.2f", value.kp)
    let type = value.observed.rawValue
    let scale = value.noaaScale?.rawValue ?? "—"
    let trend: String
    if let previousValue {
      if value.kp > previousValue.kp {
        trend = "↑"
      } else if value.kp < previousValue.kp {
        trend = "↓"
      } else {
        trend = "→"
      }
    } else {
      trend = "—"
    }

    let peakMarker: String
    if value.observed == .observed && value.kp >= maxObservedKp {
      peakMarker = " \(observedPeakMarker)"
    } else if value.observed != .observed && value.kp >= maxForecastKp {
      peakMarker = " \(forecastPeakMarker)"
    } else {
      peakMarker = ""
    }

    lines.append(
      "\(padded(date, to: 12)) \(padded(time, to: 6)) \(padded(kp, to: 5)) " +
        "\(padded(type, to: 12)) \(padded(scale, to: 4)) \(trend)\(peakMarker)"
    )
    previousValue = value
    previousDate = value.timeTag
  }

  lines.append("")
  lines.append("\(observedPeakMarker) Peak observed   \(forecastPeakMarker) Peak forecast")
  return lines.joined(separator: "\n")
}

private struct KpJSONDataPoint: Encodable {
  let kp: Double
  let noaaScale: String?

  private enum CodingKeys: String, CodingKey {
    case kp
    case noaaScale
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(kp, forKey: .kp)
    if let noaaScale {
      try container.encode(noaaScale, forKey: .noaaScale)
    } else {
      try container.encodeNil(forKey: .noaaScale)
    }
  }
}

func createKpIndexJSONReport(
  for kpData: KpIndexData,
  generatedAt: Date = Date()
) throws -> String {
  let report = CanonicalJSONReport(
    schemaVersion: 1,
    dataset: CanonicalDataset(
      id: "planetary-kp-forecast",
      name: "Planetary Kp Forecast",
      provider: "NOAA SWPC"
    ),
    generatedAt: iso8601Formatter.string(from: generatedAt),
    timeZone: "UTC",
    records: sortedValues(in: kpData).map {
      .init(
        timestamp: iso8601Formatter.string(from: $0.timeTag),
        status: $0.observed.rawValue,
        data: KpJSONDataPoint(kp: $0.kp, noaaScale: $0.noaaScale?.rawValue)
      )
    }
  )

  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  let data = try encoder.encode(report)
  guard let output = String(data: data, encoding: .utf8) else {
    throw EncodingError.invalidValue(
      report,
      .init(codingPath: [], debugDescription: "Unable to create UTF-8 JSON output.")
    )
  }
  return output
}

func createKpIndexCSVReport(for kpData: KpIndexData) -> String {
  let records = sortedValues(in: kpData).map {
    [
      iso8601Formatter.string(from: $0.timeTag),
      $0.observed.rawValue,
      String(format: "%.2f", $0.kp),
      $0.noaaScale?.rawValue ?? "",
    ].joined(separator: ",")
  }
  return (["timestamp,status,kp,noaa_scale"] + records).joined(separator: "\n")
}
