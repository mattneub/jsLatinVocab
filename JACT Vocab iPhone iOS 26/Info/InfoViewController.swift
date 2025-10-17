import UIKit
import MessageUI
import WebKit

final class InfoViewController: UIViewController, ReceiverPresenter {
    weak var processor: (any Receiver<InfoAction>)?

    lazy var webView = WKWebView().applying {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.navigationDelegate = self
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doDone))
        navigationItem.rightBarButtonItem = doneButton

        navigationItem.attributedTitle = .init("JACT Vocab Info", attributes: AttributeContainer()
            .font(UIFont(name: "Arial Rounded MT Bold", size: 20) ?? UIFont.systemFont(ofSize: 20))
        )
        navigationItem.style = .editor

        view.addSubview(self.webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        Task {
            await processor?.receive(.initialInterface)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let navigationController, navigationController.isBeingDismissed {
            webView.navigationDelegate = nil
        }
    }

    func present(_ state: InfoState) async {
        webView.loadHTMLString(state.content, baseURL: state.url)
    }

    @objc func doDone() {
        Task {
            await processor?.receive(.done)
        }
    }
}

extension InfoViewController: WKNavigationDelegate, MFMailComposeViewControllerDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void
    ) {
        if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
            if url.absoluteString == "mailto:matt@tidbits.com" && MFMailComposeViewController.canSendMail() {
                let composer = MFMailComposeViewController()
                composer.setToRecipients(["matt@tidbits.com"])
                composer.mailComposeDelegate = self
                present(composer, animated: true)
                decisionHandler(.cancel)
                return
            }
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        Task {
            await processor?.receive(.done)
        }
    }
}
