import AVFoundation

fileprivate var ASSOCIATED_CALLBACK_KEY = "ai.memorize.Audio.associatedCallbackKey"

extension AVAudioPlayer: AVAudioPlayerDelegate {
	func play(completion: ((Error?) -> Void)?) {
		objc_setAssociatedObject(self, &ASSOCIATED_CALLBACK_KEY, completion, .OBJC_ASSOCIATION_COPY_NONATOMIC)
		delegate = self
		
		guard play() else {
			completion?(nil) // TODO: Pass in error
			return
		}
	}
	
	public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
		(objc_getAssociatedObject(self, &ASSOCIATED_CALLBACK_KEY) as? (Error?) -> Void)?(error)
		objc_removeAssociatedObjects(self)
		delegate = nil
	}
	
	public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		(objc_getAssociatedObject(self, &ASSOCIATED_CALLBACK_KEY) as? (Error?) -> Void)?(
			flag
				? nil
				: nil // TODO: Pass in error
		)
		objc_removeAssociatedObjects(self)
		delegate = nil
	}
}
