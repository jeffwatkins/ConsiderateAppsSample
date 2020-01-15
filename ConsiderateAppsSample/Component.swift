//  
//  Copyright © 2020 Jeff Watkins. All rights reserved.
//

import UIKit
import Dispatch

public class Component: UIView {

    @objc public enum Orientation: Int, RawRepresentable {
        case horizontal = 0
        case vertical = 1
    }

    lazy public private(set) var contentView: UIView = createContentView()

    public var preferredOrientation: Orientation {
        didSet {
            self.createConstraints(for: self.effectiveOrientation)
        }
    }

    public private(set) var effectiveOrientation: Orientation

    public init(preferredOrientation: Orientation, frame: CGRect = CGRect.zero)
    {
        self.preferredOrientation = preferredOrientation
        self.effectiveOrientation = preferredOrientation
        super.init(frame: frame)
    }

    public override convenience init(frame: CGRect)
    {
        self.init(preferredOrientation: Orientation.horizontal, frame: frame)
    }

    public required init?(coder: NSCoder)
    {
        guard let contentView = coder.decodeObject(of: [UIView.self], forKey: "contentView") as? UIView else { return nil }

        self.preferredOrientation = Orientation(rawValue: coder.decodeInteger(forKey: "preferredOrientation")) ?? Orientation.horizontal
        self.effectiveOrientation = Orientation(rawValue: coder.decodeInteger(forKey: "effectiveOrientation")) ?? Orientation.horizontal
        super.init(coder: coder)
        self.contentView = contentView
        self.addSubview(self.contentView)
    }

    func createContentView() -> UIView {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentView.setContentHuggingPriority(.required, for: .horizontal)
        contentView.preservesSuperviewLayoutMargins = true

        self.addSubview(contentView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor))
        constraints.append(contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor))
        constraints.append(contentView.topAnchor.constraint(equalTo: self.topAnchor))
        constraints.append(contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor))
        
        // Adding a width constraint of 0 encourages the container to be as narrow as possible.
        let widthConstraint = contentView.widthAnchor.constraint(equalToConstant: 0)
        widthConstraint.priority = .defaultLow
        constraints.append(widthConstraint)

        // Adding a height constraint of 0 encourages the container to be as short as possible.
        let heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.priority = .defaultLow
        constraints.append(heightConstraint)

        NSLayoutConstraint.activate(constraints)
        return contentView
    }

    public func resetConstraints()
    {
        guard let constraints = self.componentConstraints else { return }
        NSLayoutConstraint.deactivate(constraints)
        self.componentConstraints = nil
        self.setNeedsUpdateConstraints()
    }

    public override func updateConstraints() {
        if self.componentConstraints == nil {
            self.createConstraints(for: self.effectiveOrientation)
        }
        super.updateConstraints()
    }

    public func constraintsForHorizontalOrientation() -> [NSLayoutConstraint]
    {
        return []
    }

    public func constraintsForVerticalOrientation() -> [NSLayoutConstraint]
    {
        return []
    }

    var componentConstraints: [NSLayoutConstraint]?
    public func createConstraints(for orientation: Orientation)
    {
        if let constraints = self.componentConstraints {
            NSLayoutConstraint.deactivate(constraints)
            self.componentConstraints = nil
        }

        let constraints: [NSLayoutConstraint]

        switch orientation {
            case Orientation.horizontal:
                constraints = self.constraintsForHorizontalOrientation()

            case Orientation.vertical:
                constraints = self.constraintsForVerticalOrientation()
        }

        self.componentConstraints = constraints
        NSLayoutConstraint.activate(constraints)
    }

    var shouldReflowContent: Bool {
        self.preferredOrientation == Orientation.horizontal
    }

    private var needsUpdateEffectiveOrientation = false
    public func setNeedsUpdateEffectiveOrientation() {
        guard !self.needsUpdateEffectiveOrientation else { return }
        self.needsUpdateEffectiveOrientation = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.updateEffectiveOrientation()
            self.needsUpdateEffectiveOrientation = false
        }
    }

    /// Determine the effective orientation given the available size.
    public func computeIdealOrientation() -> Orientation {
        let size = self.contentView.systemLayoutSizeFitting(CGSize.zero, withHorizontalFittingPriority: UILayoutPriority.fittingSizeLevel, verticalFittingPriority: UILayoutPriority.fittingSizeLevel)

        let availableSize = self.frame.size
        if size.width > availableSize.width {
            return .vertical
        } else {
            return .horizontal
        }
    }

    func updateEffectiveOrientation() {
        guard self.needsUpdateEffectiveOrientation else { return }

        // We only determine the correct effective orientation if reflowing the content is enabled
        guard self.shouldReflowContent else {
            self.effectiveOrientation = self.preferredOrientation
            return
        }

        // Reset constraints before measuring
        if self.preferredOrientation != self.effectiveOrientation {
            self.createConstraints(for: self.preferredOrientation)
        }
        self.contentView.setNeedsLayout()
        self.contentView.layoutSubviews()
        
        let newEffectiveOrientation = self.computeIdealOrientation()
        if newEffectiveOrientation != self.preferredOrientation {
            self.effectiveOrientation = newEffectiveOrientation
            self.createConstraints(for: self.effectiveOrientation)
            self.setNeedsUpdateConstraints()
        }
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            self.setNeedsUpdateEffectiveOrientation()
        }
    }

    public override func didMoveToSuperview() {
        /// Ensure we get a proper layout pass after being put in the view hierarchy
        guard self.superview != nil else { return }
        self.setNeedsUpdateEffectiveOrientation()
    }
    
    public override func layoutSubviews() {
        self.updateEffectiveOrientation()
        super.layoutSubviews()
    }

}
