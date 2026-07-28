//
//  firecrestHORIZON.uk
//
//  e-Mail : kieran.conlon@firecresthorizon.uk
//  Twitter: @firecrestHRZN and @Kieran_Conlon
//

import Foundation

enum SWxDataSources: String {
  case planetaryKpIndex = "NOAA Kp index forecast"
}

let swxDataSourceLocations: [SWxDataSources: String] = [
  .planetaryKpIndex: "https://services.swpc.noaa.gov/products/noaa-planetary-k-index-forecast.json"
]

enum DownloadError: LocalizedError {
  case invalidDatasetLocation(SWxDataSources)
  case invalidURL(String)
  case invalidResponse
  case unsuccessfulResponse(statusCode: Int)

  var errorDescription: String? {
    switch self {
    case .invalidDatasetLocation(let dataSource):
      return "No download location is configured for \(dataSource.rawValue)."
    case .invalidURL(let location):
      return "The dataset location is not a valid URL: \(location)"
    case .invalidResponse:
      return "NOAA returned a response that was not HTTP."
    case .unsuccessfulResponse(let statusCode):
      return "NOAA returned HTTP status \(statusCode)."
    }
  }
}

func downloadKpIndexForecast() async throws -> KpIndexData {
  let dataSet: SWxDataSources = .planetaryKpIndex
  guard let location = swxDataSourceLocations[dataSet] else {
    throw DownloadError.invalidDatasetLocation(dataSet)
  }
  let data = try await download(from: location)

  return try JSONDecoder().decode(KpIndexData.self, from: data)
}

private func download(from location: String) async throws -> Data {
  guard let url = URL(string: location) else {
    throw DownloadError.invalidURL(location)
  }
  
  let request = URLRequest(url: url)
  let (data, response) = try await URLSession.shared.data(for: request)
  
  guard let httpResponse = response as? HTTPURLResponse else {
    throw DownloadError.invalidResponse
  }
  guard 200...299 ~= httpResponse.statusCode else {
    throw DownloadError.unsuccessfulResponse(statusCode: httpResponse.statusCode)
  }
  
  return data
}
