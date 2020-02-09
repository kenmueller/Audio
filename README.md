# Audio

> The easiest way to play audio in Swift

## Methods

- `play(localUrl:fromCache:completion:)`
- `play(localUrls:fromCache:completion:)`
- `play(fileNamed:fromCache:completion:)`
- `play(filesNamed:fromCache:completion:)`
- `play(url:fromCache:completion:)`
- `play(urls:fromCache:completion:)`
- `play(data:fromCache:completion:)`

## Examples

```swift
Audio.shared.play(url: "https://www.soundjay.com/button/beep-01a.wav") { error in
	if let error = error {
		print("An error occurred: \(error)")
	} else {
		print("Done!")
	}
}
```

```swift
Audio.shared.play(urls: [
	"https://www.soundjay.com/button/beep-01a.wav", // Plays this first
	"https://www.soundjay.com/button/beep-01a.wav", // Plays this second
	"https://www.soundjay.com/button/beep-01a.wav" // Plays this third
]) { finished, error in
	if finished {
		print("All done!")
	} else if let error = error {
		print("An error occurred: \(error)")
	} else {
		print("On to the next audio URL!")
	}
}
```

```swift
// Create a new Audio environment.
// If you try to play audio at the same time in the same environment,
// the first one stops and the second one starts.
// In different environments, they play over each other.
let myAudio = Audio()

myAudio.play(fileNamed: "beep.wav")

print(myAudio.isPlaying)

myAudio.pause()

print(myAudio.isPlaying)
```
