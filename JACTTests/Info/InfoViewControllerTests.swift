@testable import Jact
import Testing
import UIKit
import WebKit
import WaitWhile

struct InfoControllerTests {
    let subject = InfoViewController()
    let processor = MockReceiver<InfoAction>()

    init() {
        subject.processor = processor
    }

    @Test("web view is correctly initialized")
    func webView() {
        let webView = subject.webView
        #expect(webView.translatesAutoresizingMaskIntoConstraints == false)
        #expect(webView.navigationDelegate === subject)
    }

    @Test("viewDidLoad: configures background color, navigation item, adds web view to interface, sends initialInterface")
    func viewDidLoad() async throws {
        let window = makeWindow(viewController: subject)
        window.layoutIfNeeded()
        #expect(subject.view.backgroundColor == .systemBackground)
        let rightButton = try #require(subject.navigationItem.rightBarButtonItem)
        #expect(rightButton.target === subject)
        #expect(rightButton.action == #selector(subject.doDone))
        let expectedTitle = AttributedString("JACT Vocab Info", attributes: AttributeContainer()
            .font(UIFont(name: "Arial Rounded MT Bold", size: 20)!)
        )
        #expect(subject.navigationItem.attributedTitle == expectedTitle)
        #expect(subject.navigationItem.style == .editor)
        #expect(subject.webView.isDescendant(of: subject.view))
        #expect(subject.webView.frame == subject.view.bounds)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialInterface])
    }

    @Test("present: loads html string and url from state into web view")
    func present() async {
        let state = InfoState(content: "howdy", url: URL(string: "http://www.example.com"))
        let webView = MockWebView()
        subject.webView = webView
        await subject.present(state)
        #expect(webView.methodsCalled == ["loadHTMLString(_:baseURL:)"])
        #expect(webView.string == "howdy")
        #expect(webView.baseUrl == URL(string: "http://www.example.com")!)
    }

    @Test("navigation controller supported orientations is all three")
    func supported() {
        let result = subject.navigationControllerSupportedInterfaceOrientations(UINavigationController())
        #expect(result == [.landscape])
    }

    // no delegate tests, not worth it; can just test in running app
}

final class MockWebView: WKWebView {
    var methodsCalled = [String]()
    var string: String?
    var baseUrl: URL?

    override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        methodsCalled.append(#function)
        self.string = string
        self.baseUrl = baseURL
        return nil
    }
}
