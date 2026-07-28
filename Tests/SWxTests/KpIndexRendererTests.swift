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

    XCTAssertTrue(chart.contains(" 5 | + |  5"))
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
