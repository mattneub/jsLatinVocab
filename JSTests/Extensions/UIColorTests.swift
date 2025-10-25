@testable import JSLatin
import Testing
import UIKit

struct UIColorTests {
    @Test("Defined colors are correct")
    func colors() {
        #expect(UIColor.myGolden.description == "UIExtendedSRGBColorSpace 1 0.894 0.541 0.9")
        #expect(UIColor.myPaler.description == "UIExtendedSRGBColorSpace 1 0.996 0.901 1")
    }
}
