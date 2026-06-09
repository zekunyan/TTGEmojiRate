import UIKit
import XCTest
import TTGEmojiRate

final class Tests: XCTestCase {
    func testRateValueClampsToSupportedRange() {
        let rateView = EmojiRateView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))

        rateView.rateValue = 8
        XCTAssertEqual(rateView.rateValue, 5)

        rateView.rateValue = -2
        XCTAssertEqual(rateView.rateValue, 0)
    }

    func testCustomizationValuesClampToSupportedRanges() {
        let rateView = EmojiRateView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))

        rateView.rateLineWidth = 40
        XCTAssertEqual(rateView.rateLineWidth, 20)

        rateView.rateMouthWidth = 0.1
        XCTAssertEqual(rateView.rateMouthWidth, 0.2)

        rateView.rateDragSensitivity = 20
        XCTAssertEqual(rateView.rateDragSensitivity, 10)
    }

    func testCustomRateRangeAndStepClampValue() {
        let rateView = EmojiRateView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        rateView.minimumRateValue = 1
        rateView.maximumRateValue = 10
        rateView.rateStep = 0.5

        rateView.rateValue = 7.24
        XCTAssertEqual(rateView.rateValue, 7)

        rateView.rateValue = 7.26
        XCTAssertEqual(rateView.rateValue, 7.5)

        rateView.rateValue = 12
        XCTAssertEqual(rateView.rateValue, 10)
    }

    func testSetRateValueAnimatedStillAppliesClampingAndStep() {
        let rateView = EmojiRateView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        rateView.rateStep = 1

        rateView.setRateValue(3.6, animated: false)
        XCTAssertEqual(rateView.rateValue, 4)
    }

    func testReadOnlyAndTapFlagsUpdateGestureAvailability() {
        let rateView = EmojiRateView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        XCTAssertEqual(rateView.gestureRecognizers?.count, 2)

        rateView.isTapToRateEnabled = false
        let recognizersWithTapDisabled = rateView.gestureRecognizers ?? []
        XCTAssertTrue(recognizersWithTapDisabled.contains { $0 is UIPanGestureRecognizer && $0.isEnabled })
        XCTAssertTrue(recognizersWithTapDisabled.contains { $0 is UITapGestureRecognizer && !$0.isEnabled })

        rateView.isReadOnly = true
        XCTAssertTrue((rateView.gestureRecognizers ?? []).allSatisfy { !$0.isEnabled })
    }
}
