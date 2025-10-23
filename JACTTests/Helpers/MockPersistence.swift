@testable import Jact

final class MockPersistence: PersistenceType {

    var methodsCalled = [String]()
    var hidden: Bool?
    var hiddenToReturn = false
    var termIndex: Int?
    var termIndexToReturn: Int?

    func setEnglishHidden(_ hidden: Bool) {
        methodsCalled.append(#function)
        self.hidden = hidden
    }
    
    func isEnglishHidden() -> Bool {
        methodsCalled.append(#function)
        return hiddenToReturn
    }

    func setCurrentTermIndex(_ index: Int) {
        methodsCalled.append(#function)
        termIndex = index
    }

    func currentTermIndex() -> Int? {
        methodsCalled.append(#function)
        return termIndexToReturn
    }


}
