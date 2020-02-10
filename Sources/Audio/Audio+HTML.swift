import Foundation

fileprivate let AUDIO_TAG_REGEX = #"<audio.*?src.*?=.*?["'](.+?)["'].*?>.*?</.*?audio.*?>"#

public extension Audio {
	static func replaceAudioTags(inHTML html: String, with value: String) -> String {
		html.replacingOccurrences(
			of: "<audio.*?>.*?</.*?audio.*?>",
			with: value,
			options: .regularExpression
		)
	}
	
	static func removeAudioTags(inHTML html: String) -> String {
		replaceAudioTags(inHTML: html, with: "")
	}
	
	/// Returns an array of `URL`s, extracted from the `src` properties of `<audio>` HTML tags.
	static func extractUrlsFromAudioTags(inHTML html: String) -> [URL] {
		html.match(AUDIO_TAG_REGEX).compactMap { match in
			match.count > 1
				? URL(string: match[1])
				: nil
		}
	}
	
	static func hasValidAudioUrlsFromAudioTags(inHTML html: String) -> Bool {
		!extractUrlsFromAudioTags(inHTML: html).isEmpty
	}
	
	/// Plays all audio extracted from the `src` properties of `<audio>` HTML tags, in sequence.
	///
	/// - Parameters:
	/// 	- inHTML: The HTML you want to parse.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when each element is finished playing, and once when they are all finished playing. The first parameter is a `Bool` that indicates if this was the final completion call. The second argument is an `Audio.Error?`, and the player will keep playing until the end even if there was an error with one of the elements.
	@discardableResult
	func playAll(
		inHTML html: String,
		fromCache: Bool = true,
		completion: ((Bool, Error?) -> Void)? = nil
	) -> Self {
		play(
			urls: Self.extractUrlsFromAudioTags(inHTML: html),
			fromCache: fromCache,
			completion: completion
		)
	}
	
	/// Plays the first audio `URL` extracted from the `src` property of an `<audio>` HTML tag.
	///
	/// - Parameters:
	/// 	- inHTML: The HTML you want to parse.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when the audio is finished playing. Takes in an optional `Audio.Error?`
	@discardableResult
	func playFirst(
		inHTML html: String,
		fromCache: Bool = true,
		completion: ((Error?) -> Void)? = nil
	) -> Self {
		guard let url = Self.extractUrlsFromAudioTags(inHTML: html).first else {
			completion?(.noValidAudioUrlsInHTML)
			return self
		}
		
		return play(url: url, fromCache: fromCache, completion: completion)
	}
	
	/// Plays the last audio `URL` extracted from the `src` property of an `<audio>` HTML tag.
	///
	/// - Parameters:
	/// 	- inHTML: The HTML you want to parse.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when the audio is finished playing. Takes in an optional `Audio.Error?`
	@discardableResult
	func playLast(
		inHTML html: String,
		fromCache: Bool = true,
		completion: ((Error?) -> Void)? = nil
	) -> Self {
		guard let url = Self.extractUrlsFromAudioTags(inHTML: html).last else {
			completion?(.noValidAudioUrlsInHTML)
			return self
		}
		
		return play(url: url, fromCache: fromCache, completion: completion)
	}
}
