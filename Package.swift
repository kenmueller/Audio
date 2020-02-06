// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "Audio",
	products: [
		.library(name: "Audio", targets: [
			"Audio"
		])
	],
	dependencies: [
		.package(
			url: "https://github.com/adamcichy/SwiftySound.git",
			from: .init(1, 2, 0)
		)
	],
	targets: [
		.target(name: "Audio", dependencies: [
			.byName(name: "SwiftySound")
		]),
		.testTarget(name: "AudioTests", dependencies: [
			"Audio"
		])
	]
)
