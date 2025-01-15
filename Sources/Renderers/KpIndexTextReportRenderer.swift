//
//  firecrestHORIZON.uk
//  🦋 @kieran.firecresthorizon.uk
//

import Foundation

func createKpIndexTextReport(for kpData: KpIndexData) -> String {
	let maxObservedKp = kpData.kpIndexValues
		.filter { $0.observed == .observed }
		.max(by: { $0.kp < $1.kp })?.kp ?? 0

	let maxPredictedKp = kpData.kpIndexValues
		.filter { $0.observed != .observed }
		.max(by: { $0.kp < $1.kp })?.kp ?? 0

	let reportLines = kpData.kpIndexValues.map { kpIndexValue -> String in
		let maxMarker = (kpIndexValue.observed == .observed && kpIndexValue.kp >= maxObservedKp) ||
		(kpIndexValue.observed != .observed && kpIndexValue.kp >= maxPredictedKp) ? " *" : ""
		return "\(kpIndexValue)\(maxMarker)"
	}

	return reportLines.joined(separator: "\n")
}
