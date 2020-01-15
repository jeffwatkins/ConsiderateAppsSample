//  
//  Copyright © 2020 Jeff Watkins. All rights reserved.
//

import UIKit

public class AdaptiveHeader: Component, HeaderComponent {

    var _title: UILabel?
    var _subtitle: UILabel?
    var _button: UIButton?

    public var title: UILabel {
        if let _title = self._title {
            return _title
        }
        let _title = UILabel()
        _title.translatesAutoresizingMaskIntoConstraints = false
        _title.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title2)
        _title.textColor = UIColor.label
        _title.adjustsFontForContentSizeCategory = true
        _title.numberOfLines = 2
        _title.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        _title.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        _title.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        self.contentView.addSubview(_title)
        self._title = _title
        self.resetConstraints()
        return _title
    }

    public var subtitle: UILabel {
        if let _subtitle = self._subtitle {
            return _subtitle
        }
        let _subtitle = UILabel()
        _subtitle.translatesAutoresizingMaskIntoConstraints = false
        _subtitle.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
        _subtitle.textColor = UIColor.secondaryLabel
        _subtitle.adjustsFontForContentSizeCategory = true
        _subtitle.numberOfLines = 2
        _subtitle.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        self.contentView.addSubview(_subtitle)
        self._subtitle = _subtitle
        self.resetConstraints()
        return _subtitle
    }

    public var button: UIButton {
        if let _button = self._button {
            return _button
        }
        let _button = UIButton(type: UIButton.ButtonType.system)
        _button.translatesAutoresizingMaskIntoConstraints = false
        _button.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        _button.titleLabel?.adjustsFontForContentSizeCategory = true
        _button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.trailing
        _button.setContentHuggingPriority(UILayoutPriority.defaultHigh + 10, for: NSLayoutConstraint.Axis.horizontal)
        _button.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        _button.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        _button.tintColor = UIColor.blue
        self.contentView.addSubview(_button)
        self._button = _button
        self.resetConstraints()
        return _button
    }

    /// This makes the protocol happy
    public required override init(preferredOrientation: Orientation, frame: CGRect) {
        super.init(preferredOrientation: preferredOrientation, frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func titleWillTruncate() -> Bool {
        guard let title = self._title, let text = title.text else {
            return false
        }

        guard text.count > 0 else {
            return false
        }

        let bounds = title.bounds
        let measureBounds = CGRect(origin: CGPoint.zero, size: CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
        let fullRect = title.textRect(forBounds: measureBounds, limitedToNumberOfLines: 0)
        let titleRect = title.textRect(forBounds: measureBounds, limitedToNumberOfLines: title.numberOfLines)
        return fullRect.height > titleRect.height;
    }

    public override func computeIdealOrientation() -> Orientation {
        if self.titleWillTruncate() {
            return .vertical
        } else {
            return .horizontal
        }
    }

    public override func constraintsForHorizontalOrientation() -> [NSLayoutConstraint] {
        let contentView = self.contentView
        let layoutMargins = contentView.layoutMarginsGuide
        var constraints = [NSLayoutConstraint]()
        var last: UIView = self.title
        var lastDescender = -self.title.font.descender

        // set up constraints when there's a title & a button
        if let title = self._title {
            title.numberOfLines = 2
            let metrics = UIFontMetrics(forTextStyle: UIFont.TextStyle.title2)
            let topAdjust = metrics.scaledValue(for: 32) - title.font.capHeight
            constraints.append(title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: topAdjust))
            constraints.append(title.leadingAnchor.constraint(equalTo: layoutMargins.leadingAnchor))
            constraints.append(title.widthAnchor.constraint(greaterThanOrEqualToConstant: 50))
            if let button = self._button {
                constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: title.trailingAnchor, multiplier: 1))
                constraints.append(button.trailingAnchor.constraint(equalTo: layoutMargins.trailingAnchor))
                constraints.append(button.firstBaselineAnchor.constraint(equalTo: title.firstBaselineAnchor))
                button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.trailing
                button.titleLabel?.numberOfLines = 1
            }
            else {
                constraints.append(title.trailingAnchor.constraint(equalTo: layoutMargins.trailingAnchor))
            }
        }

        if let subtitle = self._subtitle {
            let metrics = UIFontMetrics(forTextStyle: UIFont.TextStyle.subheadline)
            let subtitleFont = subtitle.font
            let topAdjust = metrics.scaledValue(for: 22) - lastDescender - (subtitleFont?.ascender ?? 0)
            constraints.append(subtitle.topAnchor.constraint(equalTo: last.bottomAnchor, constant: topAdjust))
            constraints.append(subtitle.leadingAnchor.constraint(equalTo: layoutMargins.leadingAnchor))
            constraints.append(subtitle.trailingAnchor.constraint(equalTo: layoutMargins.trailingAnchor))
            last = subtitle
            lastDescender = -subtitle.font.descender
        }

        let metrics = UIFontMetrics(forTextStyle: UIFont.TextStyle.body)
        let bottomPad = metrics.scaledValue(for: 16) - lastDescender
        constraints.append(contentView.bottomAnchor.constraint(equalTo: last.bottomAnchor, constant: bottomPad))

        return constraints
    }

    public override func constraintsForVerticalOrientation() -> [NSLayoutConstraint] {
        let contentView = self.contentView
        let layoutMargins = contentView.layoutMarginsGuide
        var constraints = [NSLayoutConstraint]()
        var last: UIView = self.title
        var lastDescender: CGFloat = -self.title.font.descender

        if let title = self._title {
            let metrics = UIFontMetrics(forTextStyle: UIFont.TextStyle.title2)
            let topAdjust = metrics.scaledValue(for: 32) - title.font.capHeight
            constraints.append(title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: topAdjust))
            constraints.append(title.leadingAnchor.constraint(equalTo: layoutMargins.leadingAnchor))
            constraints.append(title.trailingAnchor.constraint(equalTo: layoutMargins.trailingAnchor))
            title.numberOfLines = 4
        }

        if let subtitle = self._subtitle {
            let metrics = UIFontMetrics(forTextStyle: UIFont.TextStyle.subheadline)
            let font = subtitle.font
            let topAdjust = metrics.scaledValue(for: 22) - lastDescender - (font?.ascender ?? 0)
            constraints.append(subtitle.topAnchor.constraint(equalTo: last.bottomAnchor, constant: topAdjust))
            constraints.append(subtitle.leadingAnchor.constraint(equalTo: layoutMargins.leadingAnchor))
            constraints.append(subtitle.trailingAnchor.constraint(equalTo: layoutMargins.trailingAnchor))
            last = subtitle
            lastDescender = -subtitle.font.descender
        }

        if let button = self._button, let buttonTitle = button.titleLabel {
            let metrics = UIFontMetrics(forTextStyle: UIFont.TextStyle.body)
            let font = buttonTitle.font
            let topAdjust = metrics.scaledValue(for: 22) - lastDescender - (font?.ascender ?? 0)
            constraints.append(buttonTitle.topAnchor.constraint(equalTo: last.bottomAnchor, constant: topAdjust))
            constraints.append(button.leadingAnchor.constraint(equalTo: layoutMargins.leadingAnchor))
            constraints.append(button.trailingAnchor.constraint(equalTo: layoutMargins.trailingAnchor))
            button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.leading
            button.titleLabel?.numberOfLines = 0
            last = button
            lastDescender = -buttonTitle.font.descender
        }

        let metrics = UIFontMetrics(forTextStyle: UIFont.TextStyle.body)
        let bottomPad = metrics.scaledValue(for: 16) - lastDescender
        constraints.append(contentView.bottomAnchor.constraint(equalTo: last.bottomAnchor, constant: bottomPad))

        return constraints
    }

}
