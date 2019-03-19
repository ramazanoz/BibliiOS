//
//  SLHAnimationManager.swift
//  AkeadMobile
//
//  Created by Salih Topcu on 23.02.2019.
//  Copyright © 2019 Salih Topcu. All rights reserved.
//

import UIKit

fileprivate enum SLHAnimationManagerStatus {
    case stable
    case animating
}

public class SLHAnimationManager {
    
    private var view: UIView
    private var hasLoop: Bool
    private var initialFrame: CGRect
    private var initialAlpha: CGFloat
    private var milestones: [AnimationMilestone]
    private var currentMilestoneIndex: Int = 0
    private var wasStopped: Bool = false
    private var status: SLHAnimationManagerStatus = .stable
    
    public init(view: UIView, hasLoop: Bool, milestones: [AnimationMilestone]) {
        self.view = view
        self.initialFrame = self.view.frame
        self.initialAlpha = self.view.alpha
        self.hasLoop = hasLoop
        self.milestones = milestones
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func animate() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: {
            self.wasStopped = false
            if self.status != .animating {
                self.currentMilestoneIndex = 0
                self.goToMilestone(self.currentMilestoneIndex)
            }
        })
    }
    
    public func stop() {
        self.wasStopped = true
    }
    
    private func goToMilestone(_ index: Int) {
        if self.milestones.count > 0 && !self.wasStopped {
            //            debugPrint("")
            //            debugPrint("current index: \(index)")
            UIView.animate(withDuration: self.milestones[index].duration, delay: self.milestones[index].delay, options: self.milestones[index].options, animations: {
                self.status = .animating
                self.applyViewAttributes(self.milestones[index])
            }, completion: { finished in
                if finished {
                    self.checkForNextMilestone()
                }
            })
        }
    }
    
    private func applyViewAttributes(_ milestone: AnimationMilestone) {
        self.view.frame = milestone.frame ?? self.view.frame
        self.view.alpha = milestone.alpha ?? self.view.alpha
        //        debugPrint("current left: \(self.view.frame.origin.x)")
        //        debugPrint("current alpha: \(self.view.alpha)")
        //        if milestone.frame == nil && milestone.alpha == nil {
        //            sleep(UInt32(milestone.delay))
        //        }
        //        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        //        rotation.toValue = NSNumber(value: Double.pi * 2)
        //        rotation.duration = 1
        //        rotation.isCumulative = true
        //        rotation.repeatCount = .greatestFiniteMagnitude
        //        self.view.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    private func checkForNextMilestone() {
        if self.hasLoop && self.milestones.count > 0 && self.currentMilestoneIndex == self.milestones.count - 1 {
            self.view.frame = self.initialFrame
            self.view.alpha = self.initialAlpha
            //            debugPrint("frame reset at index: \(index)")
        }
        self.currentMilestoneIndex = (self.currentMilestoneIndex + 1) % self.milestones.count
        if self.hasLoop || self.currentMilestoneIndex < self.milestones.count - 1 {
            if self.milestones[self.currentMilestoneIndex].alpha == nil && self.milestones[self.currentMilestoneIndex].frame == nil {
                let waitingDuration = Int(self.milestones[self.currentMilestoneIndex].delay + self.milestones[self.currentMilestoneIndex].duration)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(waitingDuration * 1000), execute: {
                    self.checkForNextMilestone()
                    //                    debugPrint("waiting for: \(waitingDuration)")
                })
            } else {
                self.goToMilestone(self.currentMilestoneIndex)
            }
        } else {
            self.status = .stable
        }
    }
    
}

public struct AnimationMilestone {
    var duration: TimeInterval
    var alpha: CGFloat?
    var frame: CGRect?
    var delay: TimeInterval
    var options: UIView.AnimationOptions
    
    public init(duration: TimeInterval, alpha: CGFloat? = nil, frame: CGRect? = nil, delay: TimeInterval = 0, options: UIView.AnimationOptions = []) {
        self.duration = duration
        self.alpha = alpha
        self.frame = frame
        self.delay = delay
        self.options = options
    }
}
