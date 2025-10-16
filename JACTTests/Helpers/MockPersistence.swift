@testable import Jact

final class MockPersistence: PersistenceType {
    var methodsCalled = [String]()
    var hidden: Bool?
    var hiddenToReturn = false

    func setEnglishHidden(_ hidden: Bool) {
        methodsCalled.append(#function)
        self.hidden = hidden
    }
    
    func isEnglishHidden() -> Bool {
        methodsCalled.append(#function)
        return hiddenToReturn
    }

}
