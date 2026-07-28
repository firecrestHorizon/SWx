import Foundation
import XCTest
@testable import SWx

final class KpIndexRendererTests: XCTestCase {
  func testChartRoundsNOAAThirdStepValues() throws {
    var data = KpIndexData()
    data.kpIndexValues = [
      KpIndexValue(
        timeTag: try XCTUnwrap(DateFormatter.noaaDataFileDateTime.date(from: "2026-07-28T00:00:00")),
        kp: 5.33,
        observed: .predicted,
        noaaScale: .G1
      )
    ]

    let chart = createKpIndexTextChart(for: data)

    XCTAssertTrue(chart.contains(" Kp      G Scale"))
    XCTAssertTrue(chart.contains(" 5 ┤ ░ ├ G1"))
    XCTAssertTrue(chart.contains(" 0 └───┘"))
  }

  func testChartColorsSolidBlocksByObservationType() throws {
    let timeTag = try XCTUnwrap(
      DateFormatter.noaaDataFileDateTime.date(from: "2026-07-28T00:00:00")
    )
    var data = KpIndexData()
    data.kpIndexValues = [
      KpIndexValue(timeTag: timeTag, kp: 1.0, observed: .observed, noaaScale: nil),
      KpIndexValue(timeTag: timeTag, kp: 1.0, observed: .estimated, noaaScale: nil),
      KpIndexValue(timeTag: timeTag, kp: 1.0, observed: .predicted, noaaScale: nil),
    ]

    let chart = createKpIndexTextChart(for: data, useColor: true)

    XCTAssertTrue(
      chart.contains("\u{001B}[97m█\u{001B}[39m\u{001B}[37m█\u{001B}[39m\u{001B}[90m█\u{001B}[39m")
    )

    let monochromeChart = createKpIndexTextChart(for: data)
    XCTAssertTrue(monochromeChart.contains("█▓░"))
    XCTAssertTrue(monochromeChart.contains("Data: █ Observed  ▓ Estimated  ░ Predicted"))
    XCTAssertFalse(monochromeChart.contains("\u{001B}"))
  }

  func testAutomaticColorDetectionRejectsXcodeAndBasicOutput() {
    let terminalEnvironment = ["TERM": "xterm-256color"]
    let xcodeEnvironment = ["TERM": "xterm-256color", "OS_ACTIVITY_DT_MODE": "YES"]

    XCTAssertTrue(
      TerminalColorMode.auto.shouldUseColor(
        isTerminal: true,
        environment: terminalEnvironment
      )
    )
    XCTAssertFalse(
      TerminalColorMode.auto.shouldUseColor(
        isTerminal: true,
        environment: xcodeEnvironment
      )
    )
    XCTAssertFalse(
      TerminalColorMode.auto.shouldUseColor(
        isTerminal: false,
        environment: terminalEnvironment
      )
    )
    XCTAssertFalse(
      TerminalColorMode.auto.shouldUseColor(
        isTerminal: true,
        environment: ["NO_COLOR": ""]
      )
    )
  }

  func testChartShowsG5ForMaximumKpValue() throws {
    let timeTag = try XCTUnwrap(
      DateFormatter.noaaDataFileDateTime.date(from: "2026-07-28T00:00:00")
    )
    var data = KpIndexData()
    data.kpIndexValues = [
      KpIndexValue(timeTag: timeTag, kp: 9.0, observed: .predicted, noaaScale: .G5)
    ]

    let chart = createKpIndexTextChart(for: data)

    XCTAssertTrue(chart.contains(" 9 ┤   ├ G5"))
  }

  func testChartCanForceFullScale() throws {
    let timeTag = try XCTUnwrap(
      DateFormatter.noaaDataFileDateTime.date(from: "2026-07-28T00:00:00")
    )
    var data = KpIndexData()
    data.kpIndexValues = [
      KpIndexValue(timeTag: timeTag, kp: 1.0, observed: .observed, noaaScale: nil)
    ]

    let dynamicChart = createKpIndexTextChart(for: data)
    let fullScaleChart = createKpIndexTextChart(for: data, fullScale: true)

    XCTAssertFalse(dynamicChart.contains("G5"))
    XCTAssertTrue(fullScaleChart.contains(" 9 ┤   ├ G5"))
  }

  func testChartReportsLatestObservedTimestampInUTC() throws {
    let earlierObserved = try XCTUnwrap(
      DateFormatter.noaaDataFileDateTime.date(from: "2026-07-28T00:00:00")
    )
    let latestObserved = try XCTUnwrap(
      DateFormatter.noaaDataFileDateTime.date(from: "2026-07-28T06:00:00")
    )
    let laterPredicted = try XCTUnwrap(
      DateFormatter.noaaDataFileDateTime.date(from: "2026-07-28T09:00:00")
    )
    var data = KpIndexData()
    data.kpIndexValues = [
      KpIndexValue(timeTag: latestObserved, kp: 2.0, observed: .observed, noaaScale: nil),
      KpIndexValue(timeTag: laterPredicted, kp: 3.0, observed: .predicted, noaaScale: nil),
      KpIndexValue(timeTag: earlierObserved, kp: 1.0, observed: .observed, noaaScale: nil),
    ]

    let chart = createKpIndexTextChart(for: data)

    XCTAssertTrue(chart.contains("Latest observed: 2026-07-28 06:00 UTC"))
  }

  func testChartReportsUnavailableWhenNoObservedValuesExist() throws {
    let timeTag = try XCTUnwrap(
      DateFormatter.noaaDataFileDateTime.date(from: "2026-07-28T09:00:00")
    )
    var data = KpIndexData()
    data.kpIndexValues = [
      KpIndexValue(timeTag: timeTag, kp: 3.0, observed: .predicted, noaaScale: nil)
    ]

    let chart = createKpIndexTextChart(for: data)

    XCTAssertTrue(chart.contains("Latest observed: unavailable"))
  }

  func testChartColorsGeomagneticStormScale() throws {
    let timeTag = try XCTUnwrap(
      DateFormatter.noaaDataFileDateTime.date(from: "2026-07-28T00:00:00")
    )
    var data = KpIndexData()
    data.kpIndexValues = [
      KpIndexValue(timeTag: timeTag, kp: 1.0, observed: .observed, noaaScale: nil)
    ]

    let chart = createKpIndexTextChart(for: data, fullScale: true, useColor: true)

    XCTAssertTrue(chart.contains("├ \u{001B}[38;2;64;255;0mG1\u{001B}[39m"))
    XCTAssertTrue(chart.contains("├ \u{001B}[38;2;64;255;0mG2\u{001B}[39m"))
    XCTAssertTrue(chart.contains("├ \u{001B}[38;2;247;254;46mG3\u{001B}[39m"))
    XCTAssertTrue(chart.contains("├ \u{001B}[38;2;240;104;0mG4\u{001B}[39m"))
    XCTAssertTrue(chart.contains("├ \u{001B}[38;2;255;0;0mG5\u{001B}[39m"))
    XCTAssertTrue(chart.contains("\u{001B}[38;2;4;49;180m█\u{001B}[39m"))
    XCTAssertTrue(chart.contains("\u{001B}[38;2;0;204;255m█\u{001B}[39m"))

    let g4Band = "\u{001B}[38;2;240;104;0m█\u{001B}[39m"
    let g5Band = "\u{001B}[38;2;255;0;0m█\u{001B}[39m"
    XCTAssertEqual(chart.components(separatedBy: g4Band).count - 1, 4)
    XCTAssertEqual(chart.components(separatedBy: g5Band).count - 1, 1)
  }

  func testReportMarksHighestObservedAndForecastValues() throws {
    let timeTag = try XCTUnwrap(
      DateFormatter.noaaDataFileDateTime.date(from: "2026-07-28T00:00:00")
    )
    var data = KpIndexData()
    data.kpIndexValues = [
      KpIndexValue(timeTag: timeTag, kp: 2.0, observed: .observed, noaaScale: nil),
      KpIndexValue(timeTag: timeTag, kp: 3.0, observed: .estimated, noaaScale: nil),
      KpIndexValue(timeTag: timeTag, kp: 4.0, observed: .predicted, noaaScale: nil),
    ]

    let report = createKpIndexTextReport(for: data)
    let lines = report.split(separator: "\n")

    XCTAssertTrue(lines[0].hasSuffix(" *"))
    XCTAssertFalse(lines[1].hasSuffix(" *"))
    XCTAssertTrue(lines[2].hasSuffix(" *"))
  }
}
