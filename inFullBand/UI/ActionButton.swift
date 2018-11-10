//
//  ActionButton.swift
//  inFullBand
//
//  Created by Mikołaj Chmielewski on 08.01.2018.
//  Copyright © 2018 inFullMobile. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ActionButton: UIButton {

    // MARK: - Properties

    @IBInspectable var emojiText: String = "" {
        didSet {
            emojiLabel.text = emojiText
        }
    }

    @IBInspectable var titleText: String = "" {
        didSet {
            setTitle(titleText.uppercased(), for: .normal)
        }
    }

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.defaultBackgroundColor
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = 4
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20.0)
        return label
    }()

    override var isHighlighted: Bool {
        didSet {
            backgroundView.backgroundColor = isHighlighted ? Constants.highlightedBackgroundColor : Constants.defaultBackgroundColor
            emojiLabel.alpha = isHighlighted ? 0.7 : 1.0
        }
    }

    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        return CGSize(width: superSize.width, height: 47.0)
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUp()
    }

    private func setUp() {

        addSubview(backgroundView)
        sendSubviewToBack(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        emojiLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3.0).isActive = true

        setTitleColor(Constants.titleColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 10.0, weight: .bold)
        titleEdgeInsets = UIEdgeInsets(top: 28.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
}

private struct Constants {
    static let titleColor = UIColor(white: 220.0 / 255.0, alpha: 1.0)
    static let defaultBackgroundColor = UIColor(white: 68.0 / 255.0, alpha: 1.0)
    static let highlightedBackgroundColor = UIColor(white: 45.0 / 255.0, alpha: 1.0)
}
