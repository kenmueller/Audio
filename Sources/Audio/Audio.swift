import AVFoundation

/// The easiest way to play audio in Swift
public final class Audio {
	/// The shared `Audio` instance.
	///
	/// If you try to play audio at the same time on this instance, one will stop and the other will play.
	/// You need to create other `Audio` instances if you want a separate environment for each instance.
	public static let shared = Audio()
	
	private var player: AVAudioPlayer?
	
	private var localCache = [URL: Data]()
	private var networkCache = [URL: Data]()
	
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
	
	/// Clears both the local and network cache.
	@discardableResult
	public func clearLocalCache() -> Self {
		localCache.removeAll()
		return self
	}
	
	@discardableResult
	public func clearNetworkCache() -> Self {
		networkCache.removeAll()
		return self
	}
	
	@discardableResult
	public func clearCache() -> Self {
		localCache.removeAll()
		networkCache.removeAll()
		return self
	}
	
	private func download(url: URL, completion: @escaping (URL?, Error?) -> Void) {
		URLSession.shared.downloadTask(with: url) { localUrl, _, error in
			completion(localUrl, error)
		}.resume()
	}
	
	// MARK: - play(localUrl:fromCache:completion:)
	
	/// Plays audio from the local file system with the `URL` specified.
	///
	/// - Parameters:
	/// 	- localUrl: The `URL` on the file system.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when the audio is finished playing. Takes in an optional `Error?`
	@discardableResult
	public func play(
		localUrl url: URL,
		fromCache: Bool = true,
		completion: ((Error?) -> Void)? = nil
	) -> Self {
		do {
			if fromCache, let data = localCache[url] {
				play(data: data, completion: completion)
			} else {
				let data = try Data(contentsOf: url)
				
				localCache[url] = data
				play(data: data, completion: completion)
			}
		} catch {
			completion?(error)
		}
		
		return self
	}
	
	/// Plays audio from the local file system with the `URL` string specified.
	///
	/// - Parameters:
	/// 	- localUrl: A string representation of a `URL` on the file system.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when the audio is finished playing. Takes in an optional `Error?`
	@discardableResult
	public func play(
		localUrl url: String,
		fromCache: Bool = true,
		completion: ((Error?) -> Void)? = nil
	) -> Self {
		guard let url = URL(string: url) else {
			completion?(nil) // TODO: Pass in error
			return self
		}
		
		play(localUrl: url, fromCache: fromCache, completion: completion)
		
		return self
	}
	
	// MARK: - play(localUrls:fromCache:completion:)
	
	/// Plays audio from the local file system with the `URL`s specified, in sequence.
	///
	/// - Parameters:
	/// 	- localUrls: The `URL`s on the file system to be played in sequence.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when each element is finished playing, and once when they are all finished playing. The first parameter is a `Bool` that indicates if this was the final completion call. The second argument is an `Error?`, and the player will keep playing until the end even if there was an error with one of the elements.
	@discardableResult
	public func play(
		localUrls urls: [URL],
		fromCache: Bool = true,
		completion: ((Bool, Error?) -> Void)? = nil
	) -> Self {
		guard let url = urls.first else {
			completion?(true, nil)
			return self
		}
		
		play(localUrl: url, fromCache: fromCache) { error in
			completion?(false, error)
			
			self.play(
				localUrls: .init(urls.dropFirst()),
				fromCache: fromCache,
				completion: completion
			)
		}
		
		return self
	}
	
	/// Plays audio from the local file system with the `URL` strings specified, in sequence.
	///
	/// - Parameters:
	/// 	- localUrls: The `URL`strings on the file system to be played in sequence.
	/// 	- fromCache: If the audio is coming from the cache.
	/// 	- completion: Called when each element is finished playing, and once when they are all finished playing. The first parameter is a `Bool` that indicates if this was the final completion call. The second argument is an `Error?`, and the player will keep playing until the end even if there was an error with one of the elements.
	@discardableResult
	public func play(
		localUrls urls: [String],
		fromCache: Bool = true,
		completion: ((Bool, Error?) -> Void)? = nil
	) -> Self {
		guard let urlString = urls.first else {
			completion?(true, nil)
			return self
		}
		
		guard let url = URL(string: urlString) else {
			completion?(false, nil) // TODO: Pass in error
			return self
		}
		
		play(localUrl: url, fromCache: fromCache) { error in
			completion?(false, error)
			
			self.play(
				localUrls: .init(urls.dropFirst()),
				fromCache: fromCache,
				completion: completion
			)
		}
		
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
			completion?(nil) // TODO: Pass in error
			return self
		}
		
		return play(localUrl: url, fromCache: fromCache, completion: completion)
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
		if fromCache, let data = networkCache[url] {
			return play(data: data, completion: completion)
		}
		
		download(url: url) { localUrl, error in
			guard error == nil, let localUrl = localUrl else {
				completion?(error)
				return
			}
			
			do {
				let data = try Data(contentsOf: localUrl)
				
				self.networkCache[url] = data
				self.play(data: data, completion: completion)
			} catch {
				completion?(error)
			}
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
			completion?(nil) // TODO: Pass in error
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
			completion?(false, nil) // TODO: Pass in error
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
			completion?(error)
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
