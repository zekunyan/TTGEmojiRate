//
//  EmojiVC.swift
//  TTGEmojiRate_Example
//
//  Created by Christopher G Prince on 10/7/17.
//  Copyright © 2017 Spastic Muffin, LLC. All rights reserved.
//

import UIKit
import TTGEmojiRate

private final class DemoScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}

final class DemoCatalogViewController: UIViewController {
    private let scrollView = DemoScrollView()
    private let contentStack = UIStackView()
    private let pages = DemoContent.pages

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TTGEmojiRate"
        view.backgroundColor = Theme.background
        navigationItem.largeTitleDisplayMode = .always
        configureScrollView()
        buildContent()
    }

    private func configureScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -34),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func buildContent() {
        contentStack.addArrangedSubview(heroView())
        contentStack.addArrangedSubview(PlaygroundPanelView())
        contentStack.addArrangedSubview(pageLinksView())
    }

    private func heroView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8

        let titleLabel = UILabel()
        titleLabel.text = "Rate by dragging a feeling"
        titleLabel.font = .systemFont(ofSize: 32, weight: .heavy)
        titleLabel.numberOfLines = 2

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Start with the original up/down emoji gesture for scoring mood, then tune value, shape, fill, stroke, and custom paths."
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 4

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        return stack
    }

    private func pageLinksView() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12

        let label = UILabel()
        label.text = "Explore focused demos"
        label.font = .systemFont(ofSize: 22, weight: .heavy)
        stack.addArrangedSubview(label)

        let verticalButton = DemoLinkButton(title: "Vertical interaction", subtitle: "The original up/down emoji gesture for rating a feeling, with slider fallback.", accentColor: .systemIndigo)
        verticalButton.addTarget(self, action: #selector(openVerticalDemo), for: .touchUpInside)
        stack.addArrangedSubview(verticalButton)

        for (index, page) in pages.enumerated() {
            let button = DemoLinkButton(page: page)
            button.tag = index
            button.addTarget(self, action: #selector(openDemoPage(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
        return stack
    }

    @objc private func openDemoPage(_ sender: UIControl) {
        navigationController?.pushViewController(DemoSectionViewController(page: pages[sender.tag]), animated: true)
    }

    @objc private func openVerticalDemo() {
        navigationController?.pushViewController(VerticalInteractionViewController(), animated: true)
    }
}

private final class PlaygroundPanelView: UIView {
    private let rateView = EmojiRateView()
    private let valueLabel = UILabel()
    private let valueSlider = UISlider()
    private let lineWidthSlider = UISlider()
    private let presetControl = UISegmentedControl(items: ["Classic", "Mood", "Play", "Diag", "Min"])
    private let faceControl = UISegmentedControl(items: ["Circle", "Squircle", "Blob", "Shield"])
    private let stepControl = UISegmentedControl(items: ["Free", "0.5", "1"])
    private let gradientSwitch = UISwitch()
    private let fillSwitch = UISwitch()
    private let accessoriesSwitch = UISwitch()
    private let readOnlySwitch = UISwitch()
    private let horizontalSwitch = UISwitch()
    private var isUpdating = false

    init() {
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = .white
        layer.cornerRadius = 22
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 0, height: 10)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        let titleLabel = UILabel()
        titleLabel.text = "Interactive playground"
        titleLabel.font = .systemFont(ofSize: 22, weight: .heavy)

        let tipLabel = UILabel()
        tipLabel.text = "Tip: drag up or down on the emoji itself to rate the feeling, or use the slider for precise values."
        tipLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        tipLabel.textColor = .secondaryLabel
        tipLabel.numberOfLines = 2

        rateView.translatesAutoresizingMaskIntoConstraints = false
        rateView.backgroundColor = .clear
        rateView.minimumRateValue = 0
        rateView.maximumRateValue = 10
        rateView.rateStep = 0
        rateView.rateLineWidth = 12
        rateView.rateColorRange = (.systemCyan, .systemBlue)
        rateView.rateGradientColors = [.systemCyan, .systemBlue, .systemIndigo]
        rateView.rateGradientColorEnabled = true
        rateView.rateGestureDirection = TTGEmojiRateGestureDirection.vertical.rawValue
        rateView.emojiExpressionPreset = TTGEmojiRateExpressionPreset.expressive.rawValue
        rateView.faceShape = TTGEmojiRateFaceShape.circle.rawValue
        rateView.faceShapeMorphEnabled = false
        rateView.faceFillEnabled = true
        rateView.faceFillGradientEnabled = true
        rateView.faceFillGradientColors = [
            UIColor.systemCyan.withAlphaComponent(0.18),
            UIColor.systemBlue.withAlphaComponent(0.14)
        ]
        rateView.rateValueChangeCallback = { [weak self] value in
            self?.syncValue(value)
        }

        valueLabel.font = .systemFont(ofSize: 18, weight: .heavy)
        valueLabel.textAlignment = .center

        valueSlider.minimumValue = 0
        valueSlider.maximumValue = 10
        valueSlider.addTarget(self, action: #selector(valueSliderChanged), for: .valueChanged)
        lineWidthSlider.minimumValue = 4
        lineWidthSlider.maximumValue = 20
        lineWidthSlider.value = 12
        lineWidthSlider.addTarget(self, action: #selector(lineWidthChanged), for: .valueChanged)

        presetControl.selectedSegmentIndex = 1
        faceControl.selectedSegmentIndex = 0
        stepControl.selectedSegmentIndex = 0
        [presetControl, faceControl, stepControl].forEach { $0.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged) }

        gradientSwitch.isOn = true
        fillSwitch.isOn = true
        accessoriesSwitch.isOn = true
        horizontalSwitch.isOn = false
        [gradientSwitch, fillSwitch, accessoriesSwitch, readOnlySwitch, horizontalSwitch].forEach { $0.addTarget(self, action: #selector(switchChanged), for: .valueChanged) }

        let previewStack = UIStackView(arrangedSubviews: [rateView, valueLabel])
        previewStack.axis = .vertical
        previewStack.alignment = .center
        previewStack.spacing = 10

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(tipLabel)
        stack.addArrangedSubview(previewStack)
        stack.addArrangedSubview(controlRow("Value", valueSlider))
        stack.addArrangedSubview(controlRow("Line width", lineWidthSlider))
        stack.addArrangedSubview(controlRow("Preset", presetControl))
        stack.addArrangedSubview(controlRow("Face", faceControl))
        stack.addArrangedSubview(controlRow("Step", stepControl))
        stack.addArrangedSubview(switchGrid())

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            rateView.widthAnchor.constraint(equalToConstant: 178),
            rateView.heightAnchor.constraint(equalTo: rateView.widthAnchor)
        ])

        valueSlider.value = 7.5
        rateView.setRateValue(7.5, animated: false)
    }

    private func controlRow(_ title: String, _ control: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .secondaryLabel
        label.widthAnchor.constraint(equalToConstant: 74).isActive = true

        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        return row
    }

    private func switchGrid() -> UIView {
        let left = UIStackView(arrangedSubviews: [
            switchRow("Gradient", gradientSwitch),
            switchRow("Fill", fillSwitch),
            switchRow("Details", accessoriesSwitch)
        ])
        left.axis = .vertical
        left.spacing = 8

        let right = UIStackView(arrangedSubviews: [
            switchRow("Read only", readOnlySwitch),
            switchRow("Horizontal", horizontalSwitch)
        ])
        right.axis = .vertical
        right.spacing = 8

        let grid = UIStackView(arrangedSubviews: [left, right])
        grid.axis = .horizontal
        grid.distribution = .fillEqually
        grid.spacing = 14
        return grid
    }

    private func switchRow(_ title: String, _ control: UISwitch) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .bold)
        let row = UIStackView(arrangedSubviews: [label, control])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        return row
    }

    private func syncValue(_ value: Float) {
        valueLabel.text = String(format: "%.1f / 10", value)
        guard !isUpdating else { return }
        isUpdating = true
        valueSlider.value = value
        isUpdating = false
    }

    @objc private func valueSliderChanged() {
        guard !isUpdating else { return }
        rateView.setRateValue(valueSlider.value, animated: false)
    }

    @objc private func lineWidthChanged() {
        rateView.rateLineWidth = CGFloat(lineWidthSlider.value)
    }

    @objc private func segmentedControlChanged() {
        let presets: [TTGEmojiRateExpressionPreset] = [.classic, .expressive, .playful, .diagnostic, .minimal]
        let faces: [TTGEmojiRateFaceShape] = [.circle, .squircle, .blob, .shield]
        let steps: [Float] = [0, 0.5, 1]
        rateView.emojiExpressionPreset = presets[presetControl.selectedSegmentIndex].rawValue
        rateView.faceShape = faces[faceControl.selectedSegmentIndex].rawValue
        rateView.rateStep = steps[stepControl.selectedSegmentIndex]
    }

    @objc private func switchChanged() {
        rateView.rateGradientColorEnabled = gradientSwitch.isOn
        rateView.faceFillEnabled = fillSwitch.isOn
        rateView.emojiShowAccessories = accessoriesSwitch.isOn
        rateView.isReadOnly = readOnlySwitch.isOn
        rateView.rateGestureDirection = horizontalSwitch.isOn
            ? TTGEmojiRateGestureDirection.horizontal.rawValue
            : TTGEmojiRateGestureDirection.vertical.rawValue
    }
}

private final class DemoSectionViewController: UIViewController {
    private let page: DemoPage
    private let scrollView = DemoScrollView()
    private let contentStack = UIStackView()

    init(page: DemoPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = page.title
        view.backgroundColor = Theme.background
        configureScrollView()
        buildContent()
    }

    private func configureScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -34),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func buildContent() {
        let descriptionLabel = UILabel()
        descriptionLabel.text = page.description
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 4
        contentStack.addArrangedSubview(descriptionLabel)

        let demos = page.cases
        var index = 0
        while index < demos.count {
            if demos[index].fullWidth {
                contentStack.addArrangedSubview(DemoCardView(demo: demos[index], layout: .wide))
                index += 1
            } else {
                let row = UIStackView()
                row.axis = .horizontal
                row.distribution = .fillEqually
                row.spacing = 12
                row.addArrangedSubview(DemoCardView(demo: demos[index], layout: .compact))
                if demos.indices.contains(index + 1), !demos[index + 1].fullWidth {
                    row.addArrangedSubview(DemoCardView(demo: demos[index + 1], layout: .compact))
                    index += 2
                } else {
                    row.addArrangedSubview(UIView())
                    index += 1
                }
                contentStack.addArrangedSubview(row)
            }
        }
    }
}

final class VerticalInteractionViewController: UIViewController {
    private let rateView = EmojiRateView()
    private let slider = UISlider()
    private let valueLabel = UILabel()
    private var isUpdating = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Vertical drag"
        view.backgroundColor = Theme.background
        buildContent()
    }

    private func buildContent() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let titleLabel = UILabel()
        titleLabel.text = "Original vertical interaction"
        titleLabel.font = .systemFont(ofSize: 28, weight: .heavy)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        let tipLabel = UILabel()
        tipLabel.text = "Drag down or up directly on the emoji to change the value. Use the slider when you want precise control."
        tipLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        tipLabel.textColor = .secondaryLabel
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 4

        rateView.minimumRateValue = 0
        rateView.backgroundColor = .clear
        rateView.maximumRateValue = 10
        rateView.rateStep = 0
        rateView.rateLineWidth = 13
        rateView.rateGestureDirection = TTGEmojiRateGestureDirection.vertical.rawValue
        rateView.rateColorRange = (.systemRed, .systemGreen)
        rateView.rateGradientColorEnabled = true
        rateView.rateGradientColors = [.systemRed, .systemYellow, .systemGreen]
        rateView.emojiExpressionPreset = TTGEmojiRateExpressionPreset.expressive.rawValue
        rateView.faceShape = TTGEmojiRateFaceShape.blob.rawValue
        rateView.faceShapeMorphEnabled = true
        rateView.faceFillEnabled = true
        rateView.faceFillGradientEnabled = true
        rateView.faceFillGradientColors = [
            UIColor.systemOrange.withAlphaComponent(0.22),
            UIColor.systemGreen.withAlphaComponent(0.16)
        ]
        rateView.rateValueChangeCallback = { [weak self] value in
            self?.syncValue(value)
        }

        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        valueLabel.font = .systemFont(ofSize: 22, weight: .heavy)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(tipLabel)
        stack.addArrangedSubview(rateView)
        stack.addArrangedSubview(valueLabel)
        stack.addArrangedSubview(slider)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            rateView.widthAnchor.constraint(equalToConstant: 230),
            rateView.heightAnchor.constraint(equalTo: rateView.widthAnchor),
            slider.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])

        slider.value = 8.5
        rateView.setRateValue(8.5, animated: false)
    }

    private func syncValue(_ value: Float) {
        valueLabel.text = String(format: "%.1f / 10", value)
        guard !isUpdating else { return }
        isUpdating = true
        slider.value = value
        isUpdating = false
    }

    @objc private func sliderChanged() {
        guard !isUpdating else { return }
        rateView.setRateValue(slider.value, animated: false)
    }
}

private enum DemoCardLayout {
    case compact
    case wide
}

private final class DemoCardView: UIView {
    private let demo: DemoCase
    private let layout: DemoCardLayout
    private let rateView = EmojiRateView()
    private let valueLabel = UILabel()
    private let slider = UISlider()
    private var isUpdating = false

    init(demo: DemoCase, layout: DemoCardLayout) {
        self.demo = demo
        self.layout = layout
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = .white
        layer.cornerRadius = 18
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 8)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        let titleLabel = UILabel()
        titleLabel.text = demo.title
        titleLabel.font = .systemFont(ofSize: layout == .wide ? 22 : 17, weight: .heavy)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        let descriptionLabel = UILabel()
        descriptionLabel.text = demo.description
        descriptionLabel.font = .systemFont(ofSize: layout == .wide ? 14 : 12, weight: .semibold)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = layout == .wide ? 4 : 3

        configureRateView()

        valueLabel.font = .systemFont(ofSize: 13, weight: .bold)
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .center

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(descriptionLabel)
        stack.addArrangedSubview(rateView)
        stack.addArrangedSubview(valueLabel)

        if demo.showsSlider {
            slider.minimumValue = demo.minimum
            slider.maximumValue = demo.maximum
            slider.value = demo.value
            slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
            stack.addArrangedSubview(slider)

            let tipLabel = UILabel()
            tipLabel.text = demo.dragTip
            tipLabel.font = .systemFont(ofSize: 11, weight: .semibold)
            tipLabel.textColor = .tertiaryLabel
            tipLabel.textAlignment = .center
            tipLabel.numberOfLines = 2
            stack.addArrangedSubview(tipLabel)
        }

        if let code = demo.code {
            stack.addArrangedSubview(CodeBlockView(code))
        }

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: preferredHeight),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            rateView.widthAnchor.constraint(equalToConstant: layout == .wide ? 170 : 126),
            rateView.heightAnchor.constraint(equalTo: rateView.widthAnchor)
        ])

        if demo.showsSlider {
            slider.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.88).isActive = true
        }
    }

    private var preferredHeight: CGFloat {
        if layout == .wide {
            return demo.code == nil ? 360 : 440
        }
        return demo.code == nil ? 320 : 408
    }

    private func configureRateView() {
        rateView.backgroundColor = .clear
        rateView.minimumRateValue = demo.minimum
        rateView.maximumRateValue = demo.maximum
        rateView.rateStep = demo.step
        rateView.rateLineWidth = demo.lineWidth
        rateView.rateColorRange = demo.colorRange
        rateView.rateGradientColorEnabled = demo.gradientEnabled
        rateView.rateGradientColors = demo.gradientColors ?? [demo.colorRange.from, demo.colorRange.to]
        rateView.rateGradientStartPointX = 0
        rateView.rateGradientStartPointY = 0
        rateView.rateGradientEndPointX = 1
        rateView.rateGradientEndPointY = 1
        rateView.rateGestureDirection = demo.gestureDirection.rawValue
        rateView.recognizeSimultanousGestures = false
        rateView.isTapToRateEnabled = demo.tapToRateEnabled
        rateView.isReadOnly = demo.isReadOnly
        rateView.rateDragSensitivity = demo.dragSensitivity

        rateView.emojiExpressionPreset = demo.expressionPreset.rawValue
        rateView.emojiEyeStyle = demo.eyeStyle.rawValue
        rateView.emojiMouthStyle = demo.mouthStyle.rawValue
        rateView.emojiShowAccessories = demo.showAccessories
        rateView.emojiAccessoryScale = demo.accessoryScale

        rateView.faceShape = demo.faceShape.rawValue
        rateView.faceShapeMorphEnabled = demo.faceShapeMorphEnabled
        rateView.faceFillEnabled = demo.faceFillEnabled
        rateView.faceFillColor = demo.faceFillColor
        rateView.faceFillDynamicColor = demo.faceFillDynamicColor
        rateView.faceFillColorRange = demo.faceFillColorRange
        rateView.faceFillGradientEnabled = demo.faceFillGradientEnabled
        rateView.faceFillGradientColors = demo.faceFillGradientColors

        rateView.customEmojiPathMode = demo.customPathMode.rawValue
        rateView.customEmojiPathProvider = demo.customPath
        rateView.customFacePathProvider = demo.customFacePath

        let valueFormat = demo.valueFormat
        let maximum = demo.maximum
        rateView.rateValueChangeCallback = { [weak self] newValue in
            self?.valueLabel.text = String(format: valueFormat, newValue, maximum)
            guard let self, !self.isUpdating else { return }
            self.isUpdating = true
            self.slider.value = newValue
            self.isUpdating = false
        }
        slider.value = demo.value
        rateView.setRateValue(demo.value, animated: false)
    }

    @objc private func sliderChanged() {
        guard !isUpdating else { return }
        rateView.setRateValue(slider.value, animated: false)
    }
}

private final class CodeBlockView: UIView {
    init(_ code: String) {
        super.init(frame: .zero)
        backgroundColor = UIColor(red: 0.07, green: 0.09, blue: 0.13, alpha: 1)
        layer.cornerRadius = 10

        let label = UILabel()
        label.text = code
        label.font = .monospacedSystemFont(ofSize: 10, weight: .medium)
        label.textColor = UIColor(red: 0.88, green: 0.94, blue: 1, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class DemoLinkButton: UIControl {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let accentView = UIView()

    convenience init(page: DemoPage) {
        self.init(title: page.title, subtitle: page.description, accentColor: page.accentColor)
    }

    init(title: String, subtitle: String, accentColor: UIColor) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 14
        layer.shadowOffset = CGSize(width: 0, height: 6)
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = title
        accessibilityHint = subtitle

        accentView.backgroundColor = accentColor
        accentView.layer.cornerRadius = 4

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .heavy)
        titleLabel.numberOfLines = 2
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 3

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [accentView, textStack])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isUserInteractionEnabled = false
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 92),
            accentView.widthAnchor.constraint(equalToConstant: 8),
            accentView.heightAnchor.constraint(equalToConstant: 54),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            row.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct DemoPage {
    let title: String
    let description: String
    let accentColor: UIColor
    let cases: [DemoCase]
}

private struct DemoCase {
    let title: String
    let description: String
    var value: Float
    var minimum: Float = 0
    var maximum: Float = 10
    var step: Float = 0
    var valueFormat: String = "%.1f / %.0f"
    var lineWidth: CGFloat = 10
    var colorRange: (from: UIColor, to: UIColor) = (.systemRed, .systemGreen)
    var gradientEnabled: Bool = true
    var gradientColors: [UIColor]? = nil
    var gestureDirection: TTGEmojiRateGestureDirection = .horizontal
    var tapToRateEnabled: Bool = true
    var isReadOnly: Bool = false
    var dragSensitivity: CGFloat = 5
    var showsSlider: Bool = true
    var dragTip: String = "Drag the face itself, or use the slider."
    var fullWidth: Bool = false

    var expressionPreset: TTGEmojiRateExpressionPreset = .classic
    var eyeStyle: TTGEmojiRateEyeStyle = .automatic
    var mouthStyle: TTGEmojiRateMouthStyle = .automatic
    var showAccessories: Bool = true
    var accessoryScale: CGFloat = 1

    var faceShape: TTGEmojiRateFaceShape = .circle
    var faceShapeMorphEnabled: Bool = false
    var faceFillEnabled: Bool = false
    var faceFillColor: UIColor = UIColor.systemYellow.withAlphaComponent(0.18)
    var faceFillDynamicColor: Bool = false
    var faceFillColorRange: (from: UIColor, to: UIColor) = (
        UIColor.systemRed.withAlphaComponent(0.16),
        UIColor.systemGreen.withAlphaComponent(0.18)
    )
    var faceFillGradientEnabled: Bool = false
    var faceFillGradientColors: [UIColor] = [
        UIColor.systemYellow.withAlphaComponent(0.25),
        UIColor.systemGreen.withAlphaComponent(0.18)
    ]

    var customPathMode: TTGEmojiRateCustomPathMode = .builtIn
    var customPath: TTGEmojiRateCustomPathProvider? = nil
    var customFacePath: TTGEmojiRateCustomFacePathProvider? = nil
    var code: String? = nil
}

private enum Theme {
    static let background = UIColor(red: 0.965, green: 0.976, blue: 0.988, alpha: 1)
}

private enum DemoContent {
    static let pages: [DemoPage] = [
        DemoPage(
            title: "Start here",
            description: "Two full-width examples for vertical mood input and read-only display use cases.",
            accentColor: .systemTeal,
            cases: [
                DemoCase(
                    title: "Vertical mood rating",
                    description: "A polished 0-10 rating control where users drag the emoji up or down to express score, mood, and feeling.",
                    value: 7.5,
                    colorRange: (.systemTeal, .systemIndigo),
                    gradientColors: [.systemTeal, .systemBlue, .systemIndigo],
                    gestureDirection: .vertical,
                    dragTip: "Drag the face up or down, or use the slider.",
                    fullWidth: true,
                    expressionPreset: .expressive,
                    faceShape: .circle,
                    faceShapeMorphEnabled: false,
                    faceFillEnabled: true,
                    faceFillColor: UIColor.systemTeal.withAlphaComponent(0.12),
                    code: """
                    rateView.maximumRateValue = 10
                    rateView.rateStep = 0
                    rateView.rateGestureDirection = .vertical
                    rateView.rateValueChangeCallback = { score in }
                    """
                ),
                DemoCase(
                    title: "Read-only summary",
                    description: "For review cards, dashboards, rankings, and confirmation screens where the rating should be visible but not editable.",
                    value: 8.5,
                    colorRange: (.systemIndigo, .systemGreen),
                    gradientColors: [.systemIndigo, .systemMint, .systemGreen],
                    isReadOnly: true,
                    showsSlider: false,
                    dragTip: "Read-only: gestures are disabled.",
                    fullWidth: true,
                    expressionPreset: .expressive,
                    faceShape: .shield,
                    faceFillEnabled: true,
                    faceFillGradientEnabled: true,
                    faceFillGradientColors: [UIColor.systemIndigo.withAlphaComponent(0.16), UIColor.systemGreen.withAlphaComponent(0.14)],
                    code: """
                    rateView.isReadOnly = true
                    rateView.setRateValue(8.5, animated: true)
                    """
                )
            ]),

        DemoPage(
            title: "Emotion presets",
            description: "Preset expressions translate score into mood without requiring callers to hand-tune every curve.",
            accentColor: .systemPink,
            cases: [
                DemoCase(title: "Angry", description: "Low-score expressive face with brows and frown.", value: 1, colorRange: (.systemRed, .systemOrange), expressionPreset: .expressive),
                DemoCase(title: "Diagnostic", description: "Useful for feedback flows and problem reports.", value: 2.5, colorRange: (.systemPink, .systemTeal), expressionPreset: .diagnostic),
                DemoCase(title: "Neutral", description: "Minimal face for quiet product surfaces.", value: 5, colorRange: (.systemGray, .systemBlue), expressionPreset: .minimal),
                DemoCase(title: "Delight", description: "Reward-style high score with expressive accessories.", value: 10, colorRange: (.systemPurple, .systemGreen), gradientColors: [.systemPink, .systemYellow, .systemGreen], expressionPreset: .playful)
            ]),

        DemoPage(
            title: "Face shapes and fill",
            description: "Use filled shapes, gradient fills, and morphing outlines so every emoji does not look like the same round face.",
            accentColor: .systemBlue,
            cases: [
                DemoCase(title: "Squircle", description: "Modern rounded-square face with soft fill.", value: 7, colorRange: (.systemBlue, .systemGreen), expressionPreset: .expressive, faceShape: .squircle, faceShapeMorphEnabled: true, faceFillEnabled: true, faceFillColor: UIColor.systemBlue.withAlphaComponent(0.12)),
                DemoCase(title: "Blob", description: "Playful organic face with gradient fill.", value: 9, colorRange: (.systemPurple, .systemPink), expressionPreset: .playful, faceShape: .blob, faceShapeMorphEnabled: true, faceFillEnabled: true, faceFillGradientEnabled: true, faceFillGradientColors: [UIColor.systemYellow.withAlphaComponent(0.26), UIColor.systemPink.withAlphaComponent(0.18)]),
                DemoCase(title: "Capsule", description: "Compact horizontal rating badge.", value: 6, colorRange: (.systemIndigo, .systemTeal), expressionPreset: .minimal, faceShape: .capsule, faceFillEnabled: true, faceFillDynamicColor: true),
                DemoCase(title: "Cloud", description: "Soft cloud outline for friendly feedback.", value: 8, colorRange: (.systemCyan, .systemBlue), expressionPreset: .playful, faceShape: .cloud, faceFillEnabled: true, faceFillColor: UIColor.systemCyan.withAlphaComponent(0.16)),
                DemoCase(title: "No face", description: "Draw only expression features for minimal UI.", value: 7.5, colorRange: (.systemPink, .systemPurple), expressionPreset: .expressive, faceShape: .none),
                DemoCase(title: "Custom face", description: "Replace only the face outline and keep built-in features.", value: 8, colorRange: (.systemBrown, .systemGreen), expressionPreset: .expressive, faceFillEnabled: true, faceFillColor: UIColor.systemBrown.withAlphaComponent(0.12), customFacePath: DemoPaths.ticketFace)
            ]),

        DemoPage(
            title: "Stroke and components",
            description: "Control stroke gradient, eyes, mouth, accessories, and line width independently.",
            accentColor: .systemOrange,
            cases: [
                DemoCase(title: "Gradient stroke", description: "Multi-stop stroke gradient for richer visuals.", value: 9.5, colorRange: (.systemPurple, .systemPink), gradientColors: [.systemPurple, .systemPink, .systemOrange], expressionPreset: .playful),
                DemoCase(title: "Star eyes", description: "Override eyes and mouth while keeping score behavior.", value: 9, colorRange: (.systemOrange, .systemYellow), eyeStyle: .star, mouthStyle: .openSmile),
                DemoCase(title: "Heart eyes", description: "Another component override preset.", value: 8, colorRange: (.systemPink, .systemPurple), eyeStyle: .heart, mouthStyle: .smile),
                DemoCase(title: "Surprised", description: "Round eyes and O mouth for mid-score reaction.", value: 4.5, colorRange: (.systemIndigo, .systemTeal), eyeStyle: .round, mouthStyle: .surprise)
            ]),

        DemoPage(
            title: "Custom paths",
            description: "Full path replacement and overlay support let consumers draw product-specific or branded rating graphics.",
            accentColor: .systemPurple,
            cases: [
                DemoCase(title: "Waveform", description: "A full replacement path with face outline, eyes, and score-driven waveform mouth.", value: 6.5, lineWidth: 9, colorRange: (.systemBlue, .systemTeal), customPathMode: .replace, customPath: DemoPaths.waveform),
                DemoCase(title: "Lightning", description: "A full replacement path that keeps the face outline around a branded inner symbol.", value: 8, lineWidth: 9, colorRange: (.systemOrange, .systemPink), customPathMode: .replace, customPath: DemoPaths.lightning),
                DemoCase(title: "Crowned", description: "Overlay a custom crown on top of a built-in expression.", value: 9, colorRange: (.systemPurple, .systemGreen), expressionPreset: .expressive, customPathMode: .overlay, customPath: DemoPaths.crownOverlay),
                DemoCase(
                    title: "Path provider",
                    description: "The closure receives rect, progress, and the rate view, then draws outline and inner expression.",
                    value: 7,
                    colorRange: (.systemBlue, .systemPurple),
                    customPathMode: .replace,
                    customPath: DemoPaths.diamond,
                    code: """
                    rateView.customEmojiPathMode = .replace
                    rateView.customEmojiPathProvider = { rect, progress, view in
                        return UIBezierPath(...)
                    }
                    """
                )
            ])
    ]
}

private enum DemoPaths {
    static func waveform(rect: CGRect, progress: CGFloat, rateView: EmojiRateView) -> UIBezierPath? {
        let path = UIBezierPath()
        let width = rect.width
        let height = rect.height
        let margin = width * 0.14
        path.append(UIBezierPath(ovalIn: rect.insetBy(dx: margin, dy: margin)))

        let baseline = height * 0.56
        let amplitude = height * (0.06 + progress * 0.16)
        path.move(to: CGPoint(x: width * 0.24, y: baseline))
        for step in 1...7 {
            let x = width * (0.24 + CGFloat(step) * 0.075)
            let y = baseline + (step.isMultiple(of: 2) ? amplitude : -amplitude)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.move(to: CGPoint(x: width * 0.34, y: height * 0.36))
        path.addLine(to: CGPoint(x: width * 0.42, y: height * 0.36))
        path.move(to: CGPoint(x: width * 0.58, y: height * 0.36))
        path.addLine(to: CGPoint(x: width * 0.66, y: height * 0.36))
        return path
    }

    static func lightning(rect: CGRect, progress: CGFloat, rateView: EmojiRateView) -> UIBezierPath? {
        let width = rect.width
        let height = rect.height
        let path = UIBezierPath()
        let margin = width * 0.14

        path.append(UIBezierPath(ovalIn: rect.insetBy(dx: margin, dy: margin)))
        path.move(to: CGPoint(x: width * 0.56, y: height * 0.22))
        path.addLine(to: CGPoint(x: width * 0.36, y: height * 0.52))
        path.addLine(to: CGPoint(x: width * 0.51, y: height * 0.52))
        path.addLine(to: CGPoint(x: width * 0.42, y: height * 0.78))
        path.addLine(to: CGPoint(x: width * 0.68, y: height * 0.43))
        path.addLine(to: CGPoint(x: width * 0.52, y: height * 0.43))
        path.close()
        return path
    }

    static func crownOverlay(rect: CGRect, progress: CGFloat, rateView: EmojiRateView) -> UIBezierPath? {
        let width = rect.width
        let height = rect.height
        let path = UIBezierPath()
        let top = height * (0.12 - progress * 0.02)
        let base = height * 0.25

        path.move(to: CGPoint(x: width * 0.28, y: base))
        path.addLine(to: CGPoint(x: width * 0.36, y: top))
        path.addLine(to: CGPoint(x: width * 0.50, y: base * 0.82))
        path.addLine(to: CGPoint(x: width * 0.64, y: top))
        path.addLine(to: CGPoint(x: width * 0.72, y: base))
        path.addLine(to: CGPoint(x: width * 0.28, y: base))
        path.move(to: CGPoint(x: width * 0.32, y: base + height * 0.04))
        path.addLine(to: CGPoint(x: width * 0.68, y: base + height * 0.04))
        return path
    }

    static func diamond(rect: CGRect, progress: CGFloat, rateView: EmojiRateView) -> UIBezierPath? {
        let width = rect.width
        let height = rect.height
        let path = UIBezierPath()

        path.move(to: CGPoint(x: width * 0.5, y: height * 0.12))
        path.addLine(to: CGPoint(x: width * 0.84, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.88))
        path.addLine(to: CGPoint(x: width * 0.16, y: height * 0.5))
        path.close()
        path.move(to: CGPoint(x: width * 0.32, y: height * 0.46))
        path.addLine(to: CGPoint(x: width * 0.42, y: height * 0.46))
        path.move(to: CGPoint(x: width * 0.58, y: height * 0.46))
        path.addLine(to: CGPoint(x: width * 0.68, y: height * 0.46))
        path.move(to: CGPoint(x: width * 0.32, y: height * 0.62))
        path.addCurve(
            to: CGPoint(x: width * 0.68, y: height * 0.62),
            controlPoint1: CGPoint(x: width * 0.42, y: height * (0.68 + progress * 0.08)),
            controlPoint2: CGPoint(x: width * 0.58, y: height * (0.68 + progress * 0.08)))
        return path
    }

    static func ticketFace(rect: CGRect, progress: CGFloat, rateView: EmojiRateView) -> UIBezierPath? {
        let width = rect.width
        let height = rect.height
        let path = UIBezierPath()
        let left = width * 0.15
        let right = width * 0.85
        let top = height * 0.20
        let bottom = height * 0.80
        let notch = width * 0.08

        path.move(to: CGPoint(x: left + notch, y: top))
        path.addLine(to: CGPoint(x: right - notch, y: top))
        path.addQuadCurve(to: CGPoint(x: right, y: top + notch), controlPoint: CGPoint(x: right, y: top))
        path.addLine(to: CGPoint(x: right, y: bottom - notch))
        path.addQuadCurve(to: CGPoint(x: right - notch, y: bottom), controlPoint: CGPoint(x: right, y: bottom))
        path.addLine(to: CGPoint(x: left + notch, y: bottom))
        path.addQuadCurve(to: CGPoint(x: left, y: bottom - notch), controlPoint: CGPoint(x: left, y: bottom))
        path.addLine(to: CGPoint(x: left, y: top + notch))
        path.addQuadCurve(to: CGPoint(x: left + notch, y: top), controlPoint: CGPoint(x: left, y: top))
        path.close()
        return path
    }
}
