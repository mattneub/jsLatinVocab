import UIKit

final class DoneViewController: UIViewController {
    lazy var checkImage = UIImageView().applying {
        $0.contentMode = .center
        $0.translatesAutoresizingMaskIntoConstraints = false
        let check = NSAttributedString(
            string: "\u{2714}",
            attributes: [
                .font: UIFont(name: "ZapfDingbatsITC", size: 100) ?? UIFont.systemFont(ofSize: 100),
                .foregroundColor: UIColor.red,
                .paragraphStyle: NSMutableParagraphStyle().applying {
                    $0.alignment = .center
                }
            ]
        )
        $0.image = UIImage.imageOfSize(CGSize(width: 200, height: 200)) {
            check.draw(in: CGRect(x: 0, y: 0, width: 200, height: 200))
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(checkImage)
        NSLayoutConstraint.activate([
            checkImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
