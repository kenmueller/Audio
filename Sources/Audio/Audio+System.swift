import AVFoundation

#if os(iOS)
import UIKit
#endif

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
	
#if os(iOS)
	// MARK: - vibrate(completion:)
	
	@available(iOS 9.0, *)
	@discardableResult
	static func vibrate(completion: (() -> Void)?) -> Audio.Type {
		play(systemSoundID: kSystemSoundID_Vibrate, as: .alert, completion: completion)
	}
	
	@discardableResult
	static func vibrate() -> Audio.Type {
		play(systemSoundID: kSystemSoundID_Vibrate, as: .alert)
	}
	
	// MARK: - impact(style:intensity:)
	
	@available(iOS 10.0, *)
	typealias ImpactStyle = UIImpactFeedbackGenerator.FeedbackStyle
	
	/// Plays a sharp impact on the iOS device that users can feel.
	///
	/// - Parameters:
	/// 	- style: The style of the impact.
	@available(iOS 10.0, *)
	@discardableResult
	static func impact(style: ImpactStyle = .medium) -> Audio.Type {
		let generator = UIImpactFeedbackGenerator(style: style)
		
		generator.prepare()
		generator.impactOccurred()
		
		return self
	}
	
	/// Plays a sharp impact on the iOS device that users can feel.
	///
	/// - Parameters:
	/// 	- style: The feedback style of the impact.
	/// 	- intensity: The intensity of the impact. From `0.0` to `1.0` (inclusive).
	@available(iOS 13.0, *)
	@discardableResult
	static func impact(style: ImpactStyle = .medium, intensity: CGFloat) -> Audio.Type {
		let generator = UIImpactFeedbackGenerator(style: style)
		
		generator.prepare()
		generator.impactOccurred(intensity: intensity)
		
		return self
	}
#endif
	
#if os(macOS)
	// MARK: - flashScreen(completion:)
	
	@available(OSX 10.11, *)
	@discardableResult
	static func flashScreen(completion: (() -> Void)?) -> Audio.Type {
		play(systemSoundID: kSystemSoundID_FlashScreen, as: .alert, completion: completion)
	}
	
	@discardableResult
	static func flashScreen() -> Audio.Type {
		play(systemSoundID: kSystemSoundID_FlashScreen, as: .alert)
	}
#endif
}
