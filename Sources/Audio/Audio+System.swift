import AVFoundation

public extension Audio {
	/// Either `system` or `alert`
	enum SystemSoundType {
		case system
		case alert
	}
	
	// MARK: - play(systemSoundID:as:completion:)
	
	@available(iOS 9.0, *)
	@available(OSX 10.11, *)
	@available(tvOS 9.0, *)
	@discardableResult
	static func play(
		systemSoundID systemSoundId: SystemSoundID,
		as type: SystemSoundType = .system,
		completion: (() -> Void)?
	) -> Audio.Type {
		switch type {
		case .system:
			AudioServicesPlaySystemSoundWithCompletion(systemSoundId, completion)
		case .alert:
			AudioServicesPlayAlertSoundWithCompletion(systemSoundId, completion)
		}
		
		return self
	}
	
	@discardableResult
	static func play(
		systemSoundID systemSoundId: SystemSoundID,
		as type: SystemSoundType = .system
	) -> Audio.Type {
		switch type {
		case .system:
			AudioServicesPlaySystemSound(systemSoundId)
		case .alert:
			AudioServicesPlayAlertSound(systemSoundId)
		}
		
		return self
	}
	
	// MARK: - vibrate(completion:)
	
	@available(iOS 9.0, *)
	@available(OSX 10.11, *)
	@available(tvOS 9.0, *)
	@discardableResult
	static func vibrate(completion: (() -> Void)?) -> Audio.Type {
		play(systemSoundID: kSystemSoundID_Vibrate, as: .alert, completion: completion)
	}
	
	@discardableResult
	static func vibrate() -> Audio.Type {
		play(systemSoundID: kSystemSoundID_Vibrate, as: .alert)
	}
	
	// MARK: - flashScreen(completion:)
	
	@available(iOS 9.0, *)
	@available(OSX 10.11, *)
	@available(tvOS 9.0, *)
	@discardableResult
	static func flashScreen(completion: (() -> Void)?) -> Audio.Type {
		play(systemSoundID: kSystemSoundID_FlashScreen, as: .alert, completion: completion)
	}
	
	@discardableResult
	static func flashScreen() -> Audio.Type {
		play(systemSoundID: kSystemSoundID_FlashScreen, as: .alert)
	}
}
