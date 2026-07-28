//
//  firecrestHORIZON.uk
//
//  e-Mail : kieran.conlon@firecresthorizon.uk
//  Twitter: @firecrestHRZN and @Kieran_Conlon
//

import Foundation

enum NOAAScaleGeomagnetic: String, Decodable {
  case G1 = "G1"
  case G2 = "G2"
  case G3 = "G3"
  case G4 = "G4"
  case G5 = "G5"
}

enum KpObservationType: String, CaseIterable, Decodable {
  case observed = "observed"
  case predicted = "predicted"
  case estimated = "estimated"
}

struct KpIndexValue: Comparable {
  static func < (lhs: KpIndexValue, rhs: KpIndexValue) -> Bool {
    lhs.kp < rhs.kp
  }

  let timeTag: Date
  let kp: Double
  let observed: KpObservationType
  let noaaScale: NOAAScaleGeomagnetic?
}

extension DateFormatter {
  static let noaaDataFileDateTime: DateFormatter = {
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US_POSIX")
    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    df.timeZone = TimeZone(secondsFromGMT: 0)
    return df
  }()
}

extension KpIndexValue: Decodable {
  private enum CodingKeys: String, CodingKey {
    case timeTag = "time_tag"
    case kp
    case observed
    case noaaScale = "noaa_scale"
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    let timeTag = try container.decode(String.self, forKey: .timeTag)
    guard let dateTime = DateFormatter.noaaDataFileDateTime.date(from: timeTag) else {
      throw DecodingError.dataCorruptedError(
        forKey: .timeTag,
        in: container,
        debugDescription: "Invalid NOAA date/time: \(timeTag)"
      )
    }
    self.timeTag = dateTime
    
    self.kp = try container.decode(Double.self, forKey: .kp)
    self.observed = try container.decode(KpObservationType.self, forKey: .observed)
    self.noaaScale = try container.decodeIfPresent(NOAAScaleGeomagnetic.self, forKey: .noaaScale)
  }
}

struct KpIndexData: Decodable {
  var kpIndexValues: [KpIndexValue]
  
  init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.kpIndexValues = try container.decode([KpIndexValue].self)
  }
  
  init() {
    self.kpIndexValues = []
  }
}
