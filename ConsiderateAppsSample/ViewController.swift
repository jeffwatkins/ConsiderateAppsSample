//  
//  Copyright © 2020 Jeff Watkins. All rights reserved.
//

import UIKit

struct HeaderType {

    typealias Constructor = ((_ preferredOrientation: Component.Orientation, _ frame: CGRect) -> HeaderComponent)

    let name: String
    let constructor: Constructor

    static let flexible = HeaderType(name: "Flexible", constructor: FlexibleHeader.init)
    static let adaptive = HeaderType(name: "Adaptive", constructor: AdaptiveHeader.init)

}

class ViewController: UIViewController {

    let headerContent = [
        "en" : HeaderModel(viewControllerTitle: "Your Videos", title: "Recently Uploaded Videos", subtitle: "Your latest videos.", button: "Show All"),
        "ms" : HeaderModel(viewControllerTitle: "Video Anda", title: "Video Terkini yang Dimuat naik", subtitle: "Video terbaharu anda.", button: "Tunjukkan semua"),
        "zh" : HeaderModel(viewControllerTitle: "您的影片", title: "最近上传的视频", subtitle: "您的最新视频", button: "全部显示")
    ]

    let headerTypes = [HeaderType.flexible, HeaderType.adaptive]
    let languages = [Language.english, Language.malay, Language.chinese]

    var currentLanguage = Language.english
    var currentHeaderType = HeaderType.flexible

    func displayHeader(for language:Language, type: HeaderType) {
        let view = self.view!
        let margins = view.safeAreaLayoutGuide

        for subview in view.subviews {
            subview.removeFromSuperview()
        }

        let header = type.constructor(Component.Orientation.horizontal, CGRect.zero)
        header.preservesSuperviewLayoutMargins = true
        header.translatesAutoresizingMaskIntoConstraints = false

        if let model = self.headerContent[language.code] {
            self.title = model.viewControllerTitle
            header.title.text = model.title
            header.subtitle.text = model.subtitle
            header.button.setTitle(model.button, for: UIControl.State.normal)
        }

        view.addSubview(header)
        view.centerXAnchor.constraint(equalTo: header.centerXAnchor).isActive = true
        margins.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        view.widthAnchor.constraint(equalTo: header.widthAnchor).isActive = true

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: language.name[language.code], style: UIBarButtonItem.Style.plain, target: self, action: #selector(displayLanguageSelection))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: type.name, style: UIBarButtonItem.Style.plain, target: self, action: #selector(displayHeaderTypeSelection))

        self.currentLanguage = language
        self.currentHeaderType = type
    }

    @objc func displayHeaderTypeSelection() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for headerType in self.headerTypes {
            alert.addAction(UIAlertAction(title: headerType.name, style: UIAlertAction.Style.default, handler: { (_) in
                self.displayHeader(for: self.currentLanguage, type: headerType)
                self.dismiss(animated: true, completion: nil)
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }

    @objc func displayLanguageSelection() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for language in self.languages {
            let translation = language.name[self.currentLanguage.code]
            alert.addAction(UIAlertAction(title: translation, style: UIAlertAction.Style.default, handler: { (_) in
                self.displayHeader(for: language, type: self.currentHeaderType)
                self.dismiss(animated: true, completion: nil)
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let view = self.view!
        view.backgroundColor = UIColor.systemBackground
        self.displayHeader(for: self.currentLanguage, type: self.currentHeaderType)
    }
    
}
