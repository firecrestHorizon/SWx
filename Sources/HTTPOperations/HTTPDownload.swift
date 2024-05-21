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

enum DownloadError: Error {
  case invalidURL
  case invalidResponse
  case invaldDatasetLocation
}


func downloadKpIndexForecast() async throws -> KpIndexData {
  let dataSet: SWxDataSources = .planetaryKpIndex
  let data = try await download(from: swxDataSourceLocations[dataSet]!)
  
  return try JSONDecoder().decode(KpIndexData.self, from: data)
}

private func download(from location: String) async throws -> Data {
  guard let url = URL(string: location) else {
    throw DownloadError.invalidURL
  }
  
  let request = URLRequest(url: url)
  let (data, response) = try await URLSession.shared.data(for: request)
  
  guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
    throw DownloadError.invalidResponse
  }
  
  return data
}
