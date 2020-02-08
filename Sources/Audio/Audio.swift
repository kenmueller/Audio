import AVFoundation

/// The easiest way to play audio in Swift
public final class Audio {
	/// An error that can be thrown while playing audio
	public enum Error: LocalizedError {
		case playbackError(String)
		case unknownPlaybackError
		case invalidUrl
		
		public var localizedDescription: String {
			switch self {
			case let .playbackError(message):
				return message
			case .unknownPlaybackError:
				return "An unknown playback error occurred"
			case .invalidUrl:
				return "Invalid audio URL"
			}
		}
		
		public var errorDescription: String? {
			localizedDescription
		}
	}
	
	/// The shared `Audio` instance.
	///
	/// If you try to play audio at the same time on this instance, one will stop and the other will play.
	/// You need to create other `Audio` instances if you want a separate environment for each instance.
	public static let shared = Audio()
	
	private var player: AVAudioPlayer?
	private var cache = [URL: Data]()
	
	/// Create a new `Audio` instance.
	///
	/// Two different `Audio` instances playing audio at the same time will play over each other.
	/// If you try to play multiple things at once with a single `Audio` instance, the first one will be stopped before the second one plays.
	public init() {}
	
	public var isPlaying: Bool {
		player?.isPlaying ?? false
	}
	
	@discardableResult
	public func resume() -> Self {
		player?.play()
		return self
	}
	
	@discardableResult
	public func pause() -> Self {
		player?.pause()
		return self
	}
	
	@discardableResult
	public func stop() -> Self {
		player?.stop()
		return self
	}
	
	@discardableResult
	public func clearCache() -> Self {
		cache.removeAll()
		return self
	}
	
	// MARK: - play(fileNamed:fromCache:completion:)
	
	/// Plays audio from the local file system with name specified.
	///
	/// - Parameters:
	/// 	- fileNamed: The filename you want to play. Do not include folder names.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when the audio is finished playing. Takes in an optional `Error?`
	@discardableResult
	public func play(
		fileNamed filename: String,
		fromCache: Bool = true,
		completion: ((Error?) -> Void)? = nil
	) -> Self {
		guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
			completion?(.invalidUrl)
			return self
		}
		
		return play(url: url, fromCache: fromCache, completion: completion)
	}
	
	// MARK: - play(filesNamed:fromCache:completion:)
	
	/// Plays audio from the local file system with names specified, in sequence.
	///
	/// - Parameters:
	/// 	- filesNamed: The filenames you want to play in sequence. Do not include folder names.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when each element is finished playing, and once when they are all finished playing. The first parameter is a `Bool` that indicates if this was the final completion call. The second argument is an `Error?`, and the player will keep playing until the end even if there was an error with one of the elements.
	@discardableResult
	public func play(
		filesNamed filenames: [String],
		fromCache: Bool = true,
		completion: ((Bool, Error?) -> Void)? = nil
	) -> Self {
		guard let filename = filenames.first else {
			completion?(true, nil)
			return self
		}
		
		play(fileNamed: filename, fromCache: fromCache) { error in
			completion?(false, error)
			
			self.play(
				filesNamed: .init(filenames.dropFirst()),
				fromCache: fromCache,
				completion: completion
			)
		}
		
		return self
	}
	
	// MARK: - play(url:fromCache:completion:)
	
	/// Plays audio from a `URL`.
	///
	/// - Parameters:
	/// 	- url: The `URL` you want to play.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when the audio is finished playing. Takes in an optional `Error?`
	@discardableResult
	public func play(
		url: URL,
		fromCache: Bool = true,
		completion: ((Error?) -> Void)? = nil
	) -> Self {
		if fromCache, let data = cache[url] {
			return play(data: data, completion: completion)
		}
		
		do {
			let data = try Data(contentsOf: url)
			
			cache[url] = data
			play(data: data, completion: completion)
		} catch {
			completion?(.playbackError(error.localizedDescription))
		}
		
		return self
	}
	
	/// Plays audio from a `URL` string.
	///
	/// - Parameters:
	/// 	- url: A string representation of the `URL` you want to play.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when the audio is finished playing. Takes in an optional `Error?`
	@discardableResult
	public func play(
		url: String,
		fromCache: Bool = true,
		completion: ((Error?) -> Void)? = nil
	) -> Self {
		guard let url = URL(string: url) else {
			completion?(.invalidUrl)
			return self
		}
		
		play(url: url, fromCache: fromCache, completion: completion)
		
		return self
	}
	
	// MARK: - play(urls:fromCache:completion:)
	
	/// Plays audio in sequence from `URL`s.
	///
	/// - Parameters:
	/// 	- urls: The `URL`s you want to play in sequence.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when each element is finished playing, and once when they are all finished playing. The first parameter is a `Bool` that indicates if this was the final completion call. The second argument is an `Error?`, and the player will keep playing until the end even if there was an error with one of the elements.
	@discardableResult
	public func play(
		urls: [URL],
		fromCache: Bool = true,
		completion: ((Bool, Error?) -> Void)? = nil
	) -> Self {
		guard let url = urls.first else {
			completion?(true, nil)
			return self
		}
		
		play(url: url, fromCache: fromCache) { error in
			completion?(false, error)
			
			self.play(
				urls: .init(urls.dropFirst()),
				fromCache: fromCache,
				completion: completion
			)
		}
		
		return self
	}
	
	/// Plays audio in sequence from `URL` strings.
	///
	/// - Parameters:
	/// 	- urls: The `URL` strings you want to play in sequence.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when each element is finished playing, and once when they are all finished playing. The first parameter is a `Bool` that indicates if this was the final completion call. The second argument is an `Error?`, and the player will keep playing until the end even if there was an error with one of the elements.
	@discardableResult
	public func play(
		urls: [String],
		fromCache: Bool = true,
		completion: ((Bool, Error?) -> Void)? = nil
	) -> Self {
		guard let urlString = urls.first else {
			completion?(true, nil)
			return self
		}
		
		guard let url = URL(string: urlString) else {
			completion?(false, .invalidUrl)
			return self
		}
		
		play(url: url, fromCache: fromCache) { error in
			completion?(false, error)
			
			self.play(
				urls: .init(urls.dropFirst()),
				fromCache: fromCache,
				completion: completion
			)
		}
		
		return self
	}
	
	// MARK: - play(data:completion:)
	
	/// Plays audio from `Data`.
	///
	/// - Parameters:
	/// 	- data: The `Data` you want to play.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when the audio is finished playing. Takes in an optional `Error?`
	@discardableResult
	public func play(data: Data, completion: ((Error?) -> Void)? = nil) -> Self {
		do {
			let newPlayer = try AVAudioPlayer(data: data)
			stop()
			player = newPlayer
			
			newPlayer.play(completion: completion)
		} catch {
			completion?(.playbackError(error.localizedDescription))
		}
		
		return self
	}
	
	/// Plays audio in sequence from `Data` objects.
	///
	/// - Parameters:
	/// 	- data: The `Data` objects you want to play in sequence.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when each element is finished playing, and once when they are all finished playing. The first parameter is a `Bool` that indicates if this was the final completion call. The second argument is an `Error?`, and the player will keep playing until the end even if there was an error with one of the elements.
	@discardableResult
	public func play(data: [Data], completion: ((Bool, Error?) -> Void)? = nil) -> Self {
		guard let dataObject = data.first else {
			completion?(true, nil)
			return self
		}
		
		play(data: dataObject) { error in
			completion?(false, error)
			self.play(data: .init(data.dropFirst()), completion: completion)
		}
		
		return self
	}
}
