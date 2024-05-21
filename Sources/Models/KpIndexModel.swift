//
//  firecrestHORIZON.uk
//
//  e-Mail : kieran.conlon@firecresthorizon.uk
//  Twitter: @firecrestHRZN and @Kieran_Conlon
//

import Foundation

enum NOAAScaleGeomagnetic: String {
  case G1 = "G1"
  case G2 = "G2"
  case G3 = "G3"
  case G4 = "G4"
  case G5 = "G5"
}

enum KpObservationType: String, CaseIterable {
  case observed = "observed"
  case predicted = "predicted"
  case estimated = "estimated"
}

struct KpIndexValue {
  let timeTag: Date
  let kp: Double
  let observed: KpObservationType
  let noaaScale: NOAAScaleGeomagnetic?
}

enum KpIndexValueError: Error {
  case parsingFailed(message: String)
}

extension DateFormatter {
  static let noaaDataFileDateTime: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
    df.timeZone = TimeZone(secondsFromGMT: 0)
    return df
  }()
}

extension KpIndexValue: Decodable {
  init(from decoder: any Decoder) throws {
    var unkeyedContainer = try decoder.unkeyedContainer()
    
    guard let dateTime = try DateFormatter.noaaDataFileDateTime.date(from: unkeyedContainer.decode(String.self)) else {
      throw KpIndexValueError.parsingFailed(message: "Invalid Date/Time")
    }
    self.timeTag = dateTime
    
    guard let kpVal = try Double(unkeyedContainer.decode(String.self)) else {
      throw KpIndexValueError.parsingFailed(message: "Invalid kp value")
    }
    self.kp = kpVal
    
    let obsType = try unkeyedContainer.decode(String.self)
    if obsType == "observed" || obsType == "predicted" || obsType == "estimated" {
      self.observed = KpObservationType(rawValue: obsType)!
    } else {
      throw KpIndexValueError.parsingFailed(message: "Invalid observation value")
    }
    
    if let noaaScaleStr = try unkeyedContainer.decodeIfPresent(String.self) {
      guard let noaaScale = NOAAScaleGeomagnetic(rawValue: noaaScaleStr) else {
        throw KpIndexValueError.parsingFailed(message: "Invalid noaa_scale value")
      }
      self.noaaScale = noaaScale
    } else {
      self.noaaScale = nil
    }
  }
}

private struct DummyKpIndexValue: Codable {}

struct KpIndexData: Decodable {
  var kpIndexValues: [KpIndexValue]
  
  init(from decoder: any Decoder) throws {
    var kpIndexValues = [KpIndexValue]()
    var container = try decoder.unkeyedContainer()
    
    while !container.isAtEnd {
      if let kp = try? container.decode(KpIndexValue.self) {
        kpIndexValues.append(kp)
      } else {
        _ = try? container.decode(DummyKpIndexValue.self)  // <-- This is the trick to get the decoder to skip the header array
      }
    }
    self.kpIndexValues = kpIndexValues
  }
  
  init() {
    self.kpIndexValues = [KpIndexValue]()
  }
}
