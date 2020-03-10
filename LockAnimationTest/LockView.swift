//
//  LockView.swift
//  LockAnimationTest
//
//  Created by Ryan McLeod on 12/17/18.
//  Copyright © 2018 Grow Pixel. All rights reserved.
//

import Foundation
import UIKit

class LockView : UIView {

    // 0.0 being locked, 1.0 being unlocked
    public var progress: CGFloat = 0 {
        didSet {
            // If it ain't changed, don't animate it.
            if progress == oldValue { return }
            updateShacklePath()
        }
    }

    let shackleLayer = CAShapeLayer()
    let bodyLayer = CAShapeLayer()
    let shacklePath = UIBezierPath()

    var animator = LockViewAnimator()

    override init(frame: CGRect) {
        super.init(frame: frame)

        shackleLayer.frame = bounds
        bodyLayer.frame = bounds
        layer.addSublayer(shackleLayer)
        layer.addSublayer(bodyLayer)

        let bodyCornerRadius: CGFloat = 0.15 * frame.size.width
        let bodyWidth  = bodyLayer.bounds.size.width
        let bodyHeight = 0.6 * bodyLayer.bounds.size.height
        let bodyY      = bodyLayer.bounds.size.height - bodyHeight

        updateShacklePath()

        let bodyPath = UIBezierPath(roundedRect: CGRect(x: 0, y: bodyY, width: bodyWidth, height: bodyHeight), cornerRadius: bodyCornerRadius)
        bodyLayer.path = bodyPath.cgPath
        bodyLayer.fillColor = UIColor.white.withAlphaComponent(1).cgColor // tweak me to see inside the lock
        bodyLayer.strokeColor = UIColor.clear.cgColor

        // See: LockViewAnimator notes
        animator.lockView = self
    }

    /*
     * Draws the "shackle" or the moving, swingy bit of the lock.
     */
    private func updateShacklePath() {

        // Defines how much of the animation is devoted to the shackle first lifting up out of the lock
        // 0.2 means the shackle will lift up and out for the first 20% of the animation and swing for the last 80%
        let shackleLiftKeytime: CGFloat = 0.2
        // Calulates when the shackle will be mid swing and nudges it forward a bit to avoid a visual glitch
        // where the overlapping lines are perfectly on top of one another and we'll lose our nice round end cap
        // Remove and scrub through the animation slowly to see!
        let shackleSwingHalfWayKeytime: CGFloat = (shackleLiftKeytime + ((1.0 - shackleLiftKeytime) / 2.0))
        if abs(progress - shackleSwingHalfWayKeytime) < 0.01 {
            progress = progress + 0.01
        }

        let shackleLineWidth   = CGFloat(0.15 * frame.size.width)
        let lockCurveWidth     = ((0.79 / 2.0) * shackleLayer.bounds.size.width) - (shackleLineWidth / 2.0)
        // The total height of the shackle including the straight and curved bits
        let lockTotalHeight    = 0.4 * shackleLayer.bounds.size.height - shackleLineWidth
        let lockCurveHeight    = 0.65 * lockTotalHeight
        let lockStraightHeight = 0.35 * lockTotalHeight + shackleLineWidth // extra bit to prevent visual gapping
        // How far from the edges the shackle is inset
        let shackleInset       = CGFloat(shackleLayer.bounds.size.width - (2 * lockCurveWidth)) / 2.0
        // How far the "fixed" part of the shackle extends into the lock body
        let shackleInsetExtra  = shackleInset

        // This splits the progress value around the shackleLiftKeytime point and creates two values
        // that range from 0...1 so we can more easily animate the rest of the bits.
        // Now we can reliably use these values to know if the shackle should be all the way lifted
        // For example if shackleLiftKeytime is 0.2 then when progress is 0.15 shackleLiftProgress will be 0.75,
        // and shackleSwingProgress will be 0.0.
        let shackleLiftProgress = min(max((progress/shackleLiftKeytime), 0.0), 1.0)
        let shackleSwingProgress = min(max((progress - shackleLiftKeytime) / (1.0 - shackleLiftKeytime), 0.0), 1.0)

        // These are used for moving around to draw the shackle from bottom left up to the apex of the curve and back down
        var topY    = (shackleLineWidth / 2.0) // inset half the stroke width to prevent clipping
        topY = topY - (shackleLiftProgress * shackleInsetExtra) // moves the shackle up
        // Determines the changing horizontal position of moving side of the shackle and its center for curve calculations
        let leftX   = shackleInset + (shackleSwingProgress * 4 * lockCurveWidth)
        let centerX = shackleInset + lockCurveWidth + (shackleSwingProgress * 2 * lockCurveWidth)
        let rightX  = shackleInset + (2.0 * lockCurveWidth)

        shacklePath.removeAllPoints() // Necessary since we update the path
        // Move to the lowest point of the left/shortest side of the shackle
        shacklePath.move(to: CGPoint(x: leftX,
                                     y: (topY + lockStraightHeight + lockCurveHeight)))
        // Draw the straight part of the short side of the shackle
        shacklePath.addLine(to: CGPoint(x: leftX,
                                        y: (topY + lockCurveHeight)))
        // Draw one side of the curve
        shacklePath.addCurve(to: CGPoint(x: centerX,
                                         y: topY),
                             controlPoint1: CGPoint(x: leftX,
                                                    y: (topY + lockCurveHeight)),
                             controlPoint2: CGPoint(x: leftX,
                                                    y: topY))
        // Draw the other side of the curve
        shacklePath.addCurve(to: CGPoint(x:rightX,
                                         y: topY + lockCurveHeight),
                             controlPoint1: CGPoint(x: rightX, y: topY),
                             controlPoint2: CGPoint(x: rightX, y: (topY + lockCurveHeight)))
        // Draw the long side of the shackle
        shacklePath.addLine(to: CGPoint(x:rightX,
                                        y: (topY + lockCurveHeight + lockStraightHeight)))
        // Draw the extra bit that makes it longer (seperated for clarity
        shacklePath.addLine(to: CGPoint(x:rightX,
                                        y: (topY + lockCurveHeight + lockStraightHeight + shackleInsetExtra)))
        shackleLayer.path        = shacklePath.cgPath
        shackleLayer.strokeColor = UIColor.white.cgColor
        shackleLayer.fillColor   = UIColor.clear.cgColor
        shackleLayer.lineWidth   = shackleLineWidth
        shackleLayer.lineCap     = .round
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LockViewAnimator : NSObject {

    public weak var lockView: LockView?
    var threshold: Float = 0.01;
    public var progress: CGFloat {
        get {
            if (self.lockView == nil) {
                return 0;
            }
            return self.lockView!.progress;
        }
        set(newProgress) {
            if (self.lockView != nil) {
                self.lockView!.progress = newProgress;
            }
        }
    }
}
