// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "Audio",
	products: [
		.library(name: "Audio", targets: ["Audio"])
	],
	targets: [
		.target(name: "Audio"),
		.testTarget(name: "AudioTests", dependencies: ["Audio"])
	]
)
