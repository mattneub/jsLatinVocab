@testable import Jact
import Testing
import UIKit
import WaitWhile

struct DrillViewControllerTests {
    let subject = DrillViewController()
    let processor = MockReceiver<DrillAction>()

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

    @Test("prog is correctly prepared")
    func prog() {
        let prog = subject.prog
        #expect(prog.translatesAutoresizingMaskIntoConstraints == false)
        #expect(prog.progress == 1)
        #expect(prog.backgroundColor == .black)
        #expect(prog.trackTintColor == .black)
        #expect(prog.progressImage != nil)
    }

    @Test("blackView is correctly prepared")
    func blackView() {
        let black = subject.blackView
        #expect(black.backgroundColor == .black.withAlphaComponent(0.4))
        #expect(black.translatesAutoresizingMaskIntoConstraints == false)
    }

    @Test("pageViewController is correctly prepared")
    func pageViewController() {
        let page = subject.pageViewController
        #expect(page.transitionStyle == .pageCurl)
        #expect(page.navigationOrientation == .horizontal)
        #expect(page.spineLocation.rawValue == UIPageViewController.SpineLocation.min.rawValue)
        #expect(page.delegate === subject)
        #expect(page.viewControllers?.count == 1)
    }

    @Test("datasource is correctly prepared")
    func datasource() throws {
        let page = subject.pageViewController
        let datasource = try #require(subject.datasource as? DrillDatasource)
        #expect(datasource.processor === processor)
        #expect(datasource.pageViewController === page)
    }

    @Test("viewDidLoad: adds subviews, toolbar items; calls processor .initialInterface")
    func viewDidLoad() async throws {
        makeWindow(viewController: subject)
        subject.view.layoutIfNeeded()
        #expect(subject.imageView.superview == subject.view)
        #expect(subject.imageView.frame == subject.view.bounds)
        #expect(subject.prog.superview == subject.view)
        #expect(subject.blackView.superview == subject.view)
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
        #expect(subject.toolbar.items?.count == 3)
        let items = try #require(subject.toolbar.items)
        #expect(items[0].target === subject)
        #expect(items[0].action == #selector(subject.cancel))
        #expect(items[2].image == UIImage(named: "arrowup"))
        #expect(items[2].target === subject)
        #expect(items[2].action == #selector(subject.showEnglish))
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
        let state = DrillState(terms: [term])
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

    @Test("positionForBar: is .bottom")
    func position() {
        let result = subject.position(for: UIToolbar())
        #expect(result == .bottom)
    }

    @Test("page view controller supported orientations is landscape")
    func supported() {
        let result = subject.pageViewControllerSupportedInterfaceOrientations(UIPageViewController())
        #expect(result == [.landscape])
    }
}

fileprivate final class MockPageViewControllerDatasource: NSObject, PageViewControllerDatasourceType {
    var thingsReceived = [DrillEffect]()
    var pageViewController: UIPageViewController?
    var processor: (any Receiver<DrillAction>)?

    init(pageViewController: UIPageViewController, processor: (any Receiver<DrillAction>)?) {
        self.pageViewController = pageViewController
        self.processor = processor
    }

    var data = [Term]()

    func receive(_ effect: DrillEffect) async {
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
