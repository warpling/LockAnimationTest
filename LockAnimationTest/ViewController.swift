//
//  ViewController.swift
//  LockAnimationTest
//
//  Created by Ryan McLeod on 12/17/18.
//  Copyright © 2018 Grow Pixel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let lockView    = LockView(frame: CGRect(x: 0, y: 0, width: 50, height: 71.5))
    let slider      = UISlider()
    let sliderLabel = UILabel()
    var currentProgress: Float = 0;

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
        if (lockView.progress < 1.0) {
            lockView.progress = 0;
            currentProgress = 0.0;
            self.animatePadlockView(duration: 18.0, destination: 1.0); //Write the time you intend, times x60. No idea why.
        }
        else {
            currentProgress = 1.0;
            self.animatePadlockView(duration: 18.0, destination: 0.0); //Write the time you intend, times x60. No idea why.
        }
    }
    
    //Recursive function to remove pop dependency and animate view
    func animatePadlockView(duration: Float, destination: Float) {
        UIView.animate(withDuration: 0.01, animations: {
            self.lockView.progress = CGFloat(self.currentProgress);
        }, completion: { (success) -> Void in
            /* Destination is either 1, or 0, so we can base our decisions here*/
            //The step is 0.01 divided by total duration, multiplied by the destination, which is 1 (or a decrease by 1 so it can be skipped as a neutral multiplier).
            let animationProgress: Float = 100 * abs(destination - self.currentProgress); //This when complete will approach 0. So when times 100, it's less than 1, it's complete
            if (animationProgress > 1) {
                let stepValue: Float = 0.01 / duration;
                if (destination == 1.0) {
                    //This means values go up.
                    self.currentProgress += stepValue;
                }
                else {
                    //This means we must go to 0.
                    self.currentProgress -= stepValue;
                }
                self.animatePadlockView(duration: duration, destination: destination);
            }
            else {
                self.lockView.progress = CGFloat(destination);
            }
        })
    }
}
