import UIKit

extension UIImage {
    static func checkmark(ofSize size: CGSize) -> UIImage {
        imageOfSize(size) {
            let context = UIGraphicsGetCurrentContext()
            context?.setFillColor(UIColor.red.withAlphaComponent(0.1).cgColor)
            context?.fill(CGRect(origin: .zero, size: size))
            context?.scaleBy(x: 1.1, y: 1)
            NSAttributedString(string:"\u{2714}", attributes: [
                .font: UIFont(name: "ZapfDingbatsITC", size: 24) ?? UIFont.systemFont(ofSize: 24),
                .foregroundColor: UIColor.red,
           ]).draw(at: CGPoint(x: 5, y: 5))
        }
    }

    static func imageOfSize(_ size: CGSize, opaque: Bool = false, closure: () -> ()) -> UIImage {
        let renderer = UIGraphicsImageRenderer(
            size: size,
            format: UIGraphicsImageRendererFormat().applying {
                $0.opaque = opaque
            }
        )
        return renderer.image { _ in
            closure()
        }
    }
}
