import Foundation
import XCTest
@testable import SWx

final class KpIndexModelTests: XCTestCase {
  func testDecodesCurrentNOAAPayload() throws {
    let fixtureURL = try XCTUnwrap(
      Bundle.module.url(
        forResource: "noaa-planetary-k-index-forecast",
        withExtension: "json",
        subdirectory: "Fixtures"
      )
    )
    let data = try Data(contentsOf: fixtureURL)

    let result = try JSONDecoder().decode(KpIndexData.self, from: data)

    XCTAssertEqual(result.kpIndexValues.count, 3)
    XCTAssertEqual(result.kpIndexValues[0].kp, 1.67)
    XCTAssertEqual(result.kpIndexValues[0].observed, .observed)
    XCTAssertNil(result.kpIndexValues[0].noaaScale)
    XCTAssertEqual(result.kpIndexValues[1].observed, .estimated)
    XCTAssertEqual(result.kpIndexValues[2].observed, .predicted)
    XCTAssertEqual(result.kpIndexValues[2].noaaScale, .G1)

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
    let components = calendar.dateComponents(
      [.year, .month, .day, .hour],
      from: result.kpIndexValues[2].timeTag
    )
    XCTAssertEqual(components.year, 2026)
    XCTAssertEqual(components.month, 7)
    XCTAssertEqual(components.day, 28)
    XCTAssertEqual(components.hour, 0)
  }

  func testInvalidRecordFailsTheWholeDataset() {
    let json = """
      [
        {
          "time_tag": "not-a-date",
          "kp": 2.0,
          "observed": "predicted",
          "noaa_scale": null
        }
      ]
      """

    XCTAssertThrowsError(
      try JSONDecoder().decode(KpIndexData.self, from: Data(json.utf8))
    )
  }

  func testUnknownObservationTypeFailsDecoding() {
    let json = """
      [
        {
          "time_tag": "2026-07-28T00:00:00",
          "kp": 2.0,
          "observed": "unknown",
          "noaa_scale": null
        }
      ]
      """

    XCTAssertThrowsError(
      try JSONDecoder().decode(KpIndexData.self, from: Data(json.utf8))
    )
  }
}
