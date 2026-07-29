//
// CanonicalJSONReport.swift
// SWx
//
//  🦋 @kieran.firecresthorizon.uk
//  firecrestHORIZON.uk
//

import Foundation

struct CanonicalJSONReport<Payload: Encodable>: Encodable {
  let schemaVersion: Int
  let dataset: CanonicalDataset
  let generatedAt: String
  let timeZone: String
  let records: [CanonicalRecord<Payload>]
}

struct CanonicalDataset: Encodable {
  let id: String
  let name: String
  let provider: String
}

struct CanonicalRecord<Payload: Encodable>: Encodable {
  let timestamp: String
  let status: String
  let data: Payload
}
