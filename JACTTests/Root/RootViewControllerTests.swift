@testable import Jact
import Testing
import UIKit
import WaitWhile

struct RootViewControllerTests {
    let subject = RootViewController()
    let processor = MockReceiver<RootAction>()

    init() {
        subject.processor = processor
    }

    @Test("image view is correctly prepared")
    func imageView() {
        let imageView = subject.imageView
        #expect(imageView.image == UIImage(named: "papyrusNewLargeCropped"))
        #expect(imageView.contentMode == .scaleToFill)
        #expect(imageView.translatesAutoresizingMaskIntoConstraints == false)
    }

    @Test("toolbar is correctly prepared")
    func toolbar() {
        let toolbar = subject.toolbar
        #expect(toolbar.frame == CGRect(x: 0, y: 0, width: 100, height: 50))
        #expect(toolbar.translatesAutoresizingMaskIntoConstraints == false)
    }

    @Test("pageViewController is correctly prepared")
    func pageViewController() {
        let page = subject.pageViewController
        #expect(page.transitionStyle == .pageCurl)
        #expect(page.navigationOrientation == .horizontal)
        #expect(page.spineLocation.rawValue == UIPageViewController.SpineLocation.min.rawValue)
    }

    @Test("datasource is correctly prepared")
    func datasource() throws {
        let page = subject.pageViewController
        let datasource = try #require(subject.datasource as? RootDatasource)
        #expect(datasource.processor === processor)
        #expect(datasource.pageViewController === page)
    }

    @Test("viewDidLoad: adds image view, page view controller, toolbar; calls processor .initialInterface")
    func viewDidLoad() async throws {
        makeWindow(viewController: subject)
        subject.view.layoutIfNeeded()
        #expect(subject.imageView.superview == subject.view)
        #expect(subject.imageView.frame == subject.view.bounds)
        #expect(subject.pageViewController.view.superview == subject.view)
        #expect(subject.pageViewController.view.translatesAutoresizingMaskIntoConstraints == false)
        #expect(subject.pageViewController.view.frame == subject.view.bounds)
        #expect(subject.pageViewController.dataSource === subject.datasource)
        #expect(subject.pageViewController.delegate === subject.datasource)
        #expect(subject.toolbar.superview == subject.view)
        #expect(subject.toolbar.frame.height == 50)
        #expect(subject.toolbar.frame.width == subject.view.bounds.width)
        #expect(subject.toolbar.frame.maxY == subject.view.bounds.maxY)
        #expect(subject.toolbar.delegate === subject)
        #expect(subject.toolbar.items?.count == 9)
        let items = try #require(subject.toolbar.items)
        #expect(items[1].width == 30) // no simple way to check it is fixed space, not worth worrying about
        #expect(items[3].width == 30)
        #expect(items[5].width == 30)
        #expect(items[7].width == 30)
        #expect(items[0].image == UIImage(named: "Key"))
        #expect(items[0].target === subject)
        #expect(items[0].action == #selector(subject.toggleEnglish))
        #expect(items[2].image == UIImage(named: "folder"))
        #expect(items[2].target === subject)
        #expect(items[2].action == #selector(subject.showLessonList))
        #expect(items[4].image == UIImage(named: "magnifier"))
        #expect(items[4].target === subject)
        #expect(items[4].action == #selector(subject.showAllTermsList))
        #expect(items[6].image == UIImage(named: "bulb"))
        #expect(items[6].target === subject)
        #expect(items[6].action == #selector(subject.showLessonListDrill))
        #expect(items[8].image == UIImage(named: "help"))
        #expect(items[8].target === subject)
        #expect(items[8].action == #selector(subject.showInfo))
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .initialInterface)
    }

    @Test("present: sets datasource data")
    func present() async {
        let term = Term(
            latin: "latin", latinFirstWord: "", beta: "", english: "english", lesson: "lesson",
            section: "section", sectionFirstWord: "", lessonSection: "", part: "part",
            partFirstWord: "", lessonSectionPartFirstWord: "", indexOrig: 1, index: 2
        )
        let state = RootState(terms: [term])
        let datasource = MockPageViewControllerDatasource(
            pageViewController: UIPageViewController(),
            processor: processor
        )
        subject.datasource = datasource
        await subject.present(state)
        #expect(datasource.data == [term])
    }

    @Test("receive: passes effect on to datasource")
    func receive() async {
        let datasource = MockPageViewControllerDatasource(pageViewController: UIPageViewController(), processor: processor)
        subject.datasource = datasource
        await subject.receive(.navigateTo(index: 1, style: .forward))
        #expect(datasource.thingsReceived == [.navigateTo(index: 1, style: .forward)])
    }

    @Test("showInfo: sends showInfo")
    func showInfo() async {
        subject.showInfo()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.showInfo])
    }

    @Test("showLessonList: sends showLessonList")
    func showLessonList() async {
        subject.showLessonList()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.showLessonList])
    }

    @Test("toggleEnglish: sends toggleEnglish")
    func toggleEnglish() async {
        subject.toggleEnglish()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.toggleEnglish])
    }

    @Test("positionForBar: is .bottom")
    func position() {
        let result = subject.position(for: UIToolbar())
        #expect(result == .bottom)
    }
}

fileprivate final class MockPageViewControllerDatasource: NSObject, PageViewControllerDatasourceType {
    var thingsReceived = [RootEffect]()
    var pageViewController: UIPageViewController?
    var processor: (any Receiver<RootAction>)?

    init(pageViewController: UIPageViewController, processor: (any Receiver<RootAction>)?) {
        self.pageViewController = pageViewController
        self.processor = processor
    }

    var data = [Term]()

    func receive(_ effect: RootEffect) async {
        thingsReceived.append(effect)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        return nil
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        return nil
    }
}
