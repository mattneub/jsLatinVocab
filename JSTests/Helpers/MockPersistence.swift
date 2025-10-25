@testable import JSLatin

final class MockPersistence: PersistenceType {

    var methodsCalled = [String]()
    var hidden: Bool?
    var hiddenToReturn = false
    var showing: Bool?
    var showingToReturn = false
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

    func setExtraShowing(_ showing: Bool) {
        methodsCalled.append(#function)
        self.showing = showing
    }

    func isExtraShowing() -> Bool {
        methodsCalled.append(#function)
        return showingToReturn
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
