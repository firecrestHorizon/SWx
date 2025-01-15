//
//  firecrestHORIZON.uk
//  🦋 @kieran.firecresthorizon.uk
//

import Foundation

func createKpIndexTextReport(for kpData: KpIndexData) -> String {
	var resultString = [String]()

	let kpIndexMaxObserved = kpData.kpIndexValues.filter { kpValue in
		kpValue.observed == .observed
	}.max()

	let kpIndexMaxPredicted = kpData.kpIndexValues.filter { kpValue in
		kpValue.observed != .observed
	}.max()

	var maxMarker = ""
	for kpIndexValue in kpData.kpIndexValues {
		if (kpIndexValue.observed == .observed && kpIndexValue.kp >= (kpIndexMaxObserved?.kp ?? 0)) ||
				(kpIndexValue.observed != .observed && kpIndexValue.kp >= (kpIndexMaxPredicted?.kp ?? 0)){
			maxMarker = " *"
		} else {
			maxMarker = ""
		}

		resultString.append("\(kpIndexValue)\(maxMarker)")
	}

	return resultString.reduce("") { partialResult, value  in
		partialResult + "\(value)" + "\n"
	}
}
