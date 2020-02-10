import Foundation

extension String {
	func match(_ regex: String) -> [[String]] {
		let nsString = self as NSString
		return (try? NSRegularExpression(pattern: regex, options: []))?
			.matches(in: self, options: [], range: NSMakeRange(0, count)).map { match in
				(0..<match.numberOfRanges).map {
					match.range(at: $0).location == NSNotFound
						? ""
						: nsString.substring(with: match.range(at: $0))
				}
			} ?? []
	}
}
