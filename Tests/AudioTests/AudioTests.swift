@testable import Audio

import XCTest

final class AudioTests: XCTestCase {
	let html = """
	<!DOCTYPE html>
	<html>
		<body>
			<audio controls src="https://example.com/audio"></audio>
			<audio controls src="https://example.com/other-audio"></audio>
		</body>
	</html>
	"""
	
	func test_replaceAudioTags() {
		let modifiedHtml = Audio.replaceAudioTags(inHTML: html, with: "__AUDIO__")
		let expectedHtml = """
		<!DOCTYPE html>
		<html>
			<body>
				__AUDIO__
				__AUDIO__
			</body>
		</html>
		"""
		
		XCTAssertEqual(modifiedHtml, expectedHtml)
	}
	
	func test_removeAudioTags() {
		let modifiedHtml = Audio.removeAudioTags(inHTML: html)
		let expectedHtml = """
		<!DOCTYPE html>
		<html>
			<body>
				
				
			</body>
		</html>
		"""
		
		XCTAssertEqual(modifiedHtml, expectedHtml)
	}
	
	func test_extractUrlsFromAudioTags() {
		let urls = Audio.extractUrlsFromAudioTags(inHTML: html)
		
		XCTAssertEqual(urls, [
			URL(string: "https://example.com/audio")!,
			URL(string: "https://example.com/other-audio")!
		])
	}
}
