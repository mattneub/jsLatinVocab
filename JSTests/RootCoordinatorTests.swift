import UIKit
@testable import JSLatin
import Testing
import WaitWhile

struct RootCoordinatorTests {
    @Test("createInterface: configures initial module correctly")
    func createInterface() throws {
        let subject = RootCoordinator()
        let window = UIWindow()
        subject.createInterface(window: window)
        let viewController = try #require(subject.rootViewController as? RootViewController)
        let processor = try #require(viewController.processor as? RootProcessor)
        #expect(subject.rootProcessor === processor)
        #expect(processor.presenter === viewController)
        #expect(processor.coordinator === subject)
        #expect(window.rootViewController === viewController)
        #expect(window.backgroundColor == .systemBackground)
    }

    @Test("showInfo: configures info module, presents navigation controller")
    func showInfo() async throws {
        let subject = RootCoordinator()
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        subject.rootViewController = viewController
        subject.showInfo()
        let processor = try #require(subject.infoProcessor as? InfoProcessor)
        let infoController = try #require(processor.presenter as? InfoViewController)
        #expect(processor.coordinator === subject)
        #expect(infoController.processor === processor)
        await #while(viewController.presentedViewController == nil)
        let navigationController = try #require(viewController.presentedViewController as? UINavigationController)
        #expect(navigationController.viewControllers.first === infoController)
        #expect(navigationController.modalPresentationStyle == .fullScreen)
        #expect(navigationController.modalTransitionStyle == .flipHorizontal)
        #expect(navigationController.delegate === infoController)
    }

    @Test("showLessonList: configures lesson list module, configures state, sets delegate, presents navigation controller")
    func showLessonList() async throws {
        let subject = RootCoordinator()
        subject.rootProcessor = RootProcessor()
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        subject.rootViewController = viewController
        let term1 = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        let term2 = Term(
            latin: "latin2", latinFirstWord: "", beta: "", english: "english2", lesson: "lesson2",
            section: "section2", sectionFirstWord: "", lessonSection: "", part: "part2",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 3
        )
        subject.showLessonList(terms: [term1, term2])
        let processor = try #require(subject.lessonListProcessor as? LessonListProcessor)
        let lessonListController = try #require(processor.presenter as? LessonListViewController)
        #expect(processor.coordinator === subject)
        #expect(processor.state.terms == [term1, term2])
        #expect(processor.delegate === subject.rootProcessor)
        #expect(lessonListController.processor === processor)
        await #while(viewController.presentedViewController == nil)
        let navigationController = try #require(viewController.presentedViewController as? UINavigationController)
        #expect(navigationController.viewControllers.first === lessonListController)
        #expect(navigationController.modalPresentationStyle == .fullScreen)
        #expect(navigationController.delegate === lessonListController)
    }

    @Test("showLessonListDrill: configures lesson list drill module, configures state, presents navigation controller")
    func showLessonListDrill() async throws {
        let subject = RootCoordinator()
        subject.rootProcessor = RootProcessor()
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        subject.rootViewController = viewController
        let term1 = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        let term2 = Term(
            latin: "latin2", latinFirstWord: "", beta: "", english: "english2", lesson: "lesson2",
            section: "section2", sectionFirstWord: "", lessonSection: "", part: "part2",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 3
        )
        subject.showLessonListDrill(terms: [term1, term2])
        let processor = try #require(subject.lessonListDrillProcessor as? LessonListDrillProcessor)
        let lessonListDrillController = try #require(processor.presenter as? LessonListDrillViewController)
        #expect(processor.coordinator === subject)
        #expect(processor.state.terms == [term1, term2])
        #expect(lessonListDrillController.processor === processor)
        await #while(viewController.presentedViewController == nil)
        let navigationController = try #require(viewController.presentedViewController as? UINavigationController)
        #expect(navigationController.viewControllers.first === lessonListDrillController)
        #expect(navigationController.modalPresentationStyle == .fullScreen)
        #expect(navigationController.delegate === lessonListDrillController)
    }

    @Test("showAllTerms: configures all terms module, configures state, sets delegate, presents navigation controller")
    func showAllTerms() async throws {
        let subject = RootCoordinator()
        subject.rootProcessor = RootProcessor()
        let viewController = RootViewController()
        makeWindow(viewController: viewController)
        subject.rootViewController = viewController
        let term1 = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        let term2 = Term(
            latin: "latin2", latinFirstWord: "", beta: "", english: "english2", lesson: "lesson2",
            section: "section2", sectionFirstWord: "", lessonSection: "", part: "part2",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 2, index: 3
        )
        #expect(viewController.interfaceOrientations == [.landscape])
        subject.showAllTerms(terms: [term1, term2])
        let processor = try #require(subject.allTermsProcessor as? AllTermsProcessor)
        let allTermsController = try #require(processor.presenter as? AllTermsViewController)
        #expect(processor.coordinator === subject)
        #expect(processor.state.terms == [term1, term2])
        #expect(processor.delegate === subject.rootProcessor)
        #expect(allTermsController.processor === processor)
        await #while(viewController.presentedViewController == nil)
        let navigationController = try #require(viewController.presentedViewController as? UINavigationController)
        #expect(navigationController.viewControllers.first === allTermsController)
        #expect(navigationController.modalPresentationStyle == .overFullScreen)
        #expect(navigationController.delegate === allTermsController)
        await #while(viewController.interfaceOrientations == [.landscape])
        #expect(viewController.interfaceOrientations == [.portrait])
    }

    @Test("showDrill: constructs drill module, configures state, presents on existing presented")
    func showDrill() async throws {
        let string1 = "latin1\tenglish\t2\ta\tpart"
        let string2 = "latin2\tenglish\t1\tb\tpart"
        let string3 = "latin3\tenglish\t1\tb another word\tpart"
        let string4 = "latin4\tenglish\t1\tc\tpart"
        let terms = [string1, string2, string3, string4].map { Term(tabbedString: $0, index: 0)}
        let subject = RootCoordinator()
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        subject.rootViewController = viewController
        viewController.present(UIViewController(), animated: false)
        subject.showDrill(terms: terms)
        let processor = try #require(subject.drillProcessor as? DrillProcessor)
        #expect(processor.state.terms == terms)
        let drillController = try #require(processor.presenter as? DrillViewController)
        #expect(processor.coordinator === subject)
        #expect(drillController.processor === processor)
        await #while(viewController.presentedViewController?.presentedViewController == nil)
        #expect(drillController.modalPresentationStyle == .overFullScreen)
        #expect(viewController.presentedViewController?.presentedViewController === drillController)
    }

    @Test("dismiss: dismisses from root view controller")
    func dismiss() async throws {
        let subject = RootCoordinator()
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        subject.rootViewController = viewController
        let viewController2 = UIViewController()
        viewController.present(viewController2, animated: false)
        await #while(viewController.presentedViewController == nil)
        #expect(viewController.presentedViewController === viewController2)
        await subject.dismiss()
        await #while(viewController.presentedViewController != nil)
        #expect(viewController.presentedViewController == nil)
    }

    @Test("dismiss: if two levels of presentation, dismisses last level only")
    func dismissTwoLevels() async throws {
        let subject = RootCoordinator()
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        subject.rootViewController = viewController
        let viewController2 = UIViewController()
        viewController.present(viewController2, animated: false)
        await #while(viewController.presentedViewController == nil)
        #expect(viewController.presentedViewController === viewController2)
        let viewController3 = UIViewController()
        viewController2.present(viewController3, animated: false)
        await #while(viewController2.presentedViewController == nil)
        #expect(viewController2.presentedViewController === viewController3)
        await subject.dismiss()
        await #while(viewController.presentedViewController?.presentedViewController != nil)
        #expect(viewController.presentedViewController?.presentedViewController == nil)
        #expect(viewController.presentedViewController === viewController2)
    }
}
