//
//  ViewController.swift
//  LockAnimationTest
//
//  Created by Ryan McLeod on 12/17/18.
//  Copyright © 2018 Grow Pixel. All rights reserved.
//

import UIKit
import pop

class ViewController: UIViewController {

    let lockView    = LockView(frame: CGRect(x: 0, y: 0, width: 50, height: 71.5))
    let slider      = UISlider()
    let sliderLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(white: 0.3, alpha: 1)

        lockView.clipsToBounds = false
        lockView.center = view.center

        slider.frame = CGRect(x: 50,
                              y: view.bounds.size.height - 100,
                              width: view.bounds.size.width - 100,
                              height: 40)
        slider.addTarget(self, action: #selector(updateLock(sender:)), for: .valueChanged)

        sliderLabel.frame = CGRect(x: slider.frame.origin.x,
                                   y: slider.frame.origin.y - 20,
                                   width: slider.frame.size.width,
                                   height: 20)
        sliderLabel.textColor = .white
        sliderLabel.textAlignment = .center
        sliderLabel.font = UIFont.systemFont(ofSize: 12)
        sliderLabel.text = "tap lock to animate"

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        lockView.addGestureRecognizer(tapGesture)

        view.addSubview(lockView)
        view.addSubview(slider)
        view.addSubview(sliderLabel)
    }

    @IBAction func updateLock(sender: UISlider) {
        let truncatedValue = round(100*(sender.value)) / 100.0
        sliderLabel.text = String(format: "%0.2f", truncatedValue)
        // Note: Not sure if this helps at all?
        DispatchQueue.main.async {
            self.lockView.progress = CGFloat(truncatedValue)
        }
    }

    @IBAction func tap(sender: UISlider) {
        // Run a fixed animation to (un)lock depending on current progress
        let lockAnimation = POPBasicAnimation()
        lockAnimation.property = lockView.animator.animatableProperty()
        lockAnimation.fromValue = lockView.progress < 1.0 ? 0.0 : 1.0
        lockAnimation.toValue = lockView.progress < 1.0 ? 1.0 : 0.0
        lockAnimation.duration = 0.35
        lockAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        lockView.animator.pop_add(lockAnimation, forKey: "lock")
    }
}
