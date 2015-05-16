/*

Copyright (c) 2015 Jeff Menter

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import UIKit

class AccurateSlider: UISlider {

    private var leftCaliper = UIView()
    private var rightCaliper = UIView()
    private var leftTrack = UIView()
    private var rightTrack = UIView()
    private var trackRect = CGRectZero
    private let calipers:[UIView]
    private let tracks:[UIView]
    private let calipersAndTracks:[UIView]
    
    //MARK: - Setup Etc.
    
    required init(coder aDecoder: NSCoder) {
        calipers = [leftCaliper, rightCaliper]
        tracks = [leftTrack, rightTrack]
        calipersAndTracks = calipers + tracks
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        trackRect = trackRectForBounds(bounds)
        
        calipers.map({ self.styleCaliperView($0) })
        tracks.map({ self.styleTrackView($0) })
        
        calipersAndTracks.map({ $0.alpha = 0 })
        calipersAndTracks.map({ self.superview?.addSubview($0) })
        
        resetCaliperRects()
    }
    
    private func styleCaliperView(view:UIView) {
        view.backgroundColor = UIColor.whiteColor()
        view.frame = CGRect(x: 0, y: 0, width: 2, height: 28)
        view.layer.shadowColor = UIColor.blackColor().CGColor;
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        view.layer.cornerRadius = 1
    }
    
    private func styleTrackView(view:UIView) {
        view.backgroundColor = (superview?.backgroundColor ?? UIColor.whiteColor()).colorWithAlphaComponent(0.75)
        view.layer.cornerRadius = 1
    }
    
    private func resetCaliperRects() {
        leftCaliper.frame.origin.x = frame.origin.x + 2.0
        leftCaliper.frame.origin.y = frame.origin.y + 1.0
        rightCaliper.frame.origin.x = frame.origin.x + frame.size.width - 4.0
        rightCaliper.frame.origin.y = frame.origin.y + 1
        leftTrack.frame = CGRect(x: frame.origin.x + trackRect.origin.x, y: frame.origin.y + trackRect.origin.y, width: 2, height: trackRect.size.height)
        rightTrack.frame = CGRect(x: frame.origin.x + frame.size.width - 2 - trackRect.origin.x, y: frame.origin.y + trackRect.origin.y, width: 2, height: trackRect.size.height)
    }
    
    //MARK: - UIControl Touch Tracking
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        resetCaliperRects()
        UIView.animateWithDuration(0.2, animations: { self.calipersAndTracks.map({ $0.alpha = 1 }) })
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let verticalTouchDelta = fabs(touch.locationInView(self).y - (frame.size.height / 2.0))
        let shouldTrackNormally = (verticalTouchDelta < frame.size.height * 2.0)
        if shouldTrackNormally {
            UIView.animateWithDuration(0.4, animations: { self.resetCaliperRects() })
            return super.continueTrackingWithTouch(touch, withEvent: event)
        }
        
        let trackingHorizontalDelta = touch.locationInView(self).x - touch.previousLocationInView(self).x
        let valueDivisor = fabs(verticalTouchDelta / frame.size.height)
        let valueRange = CGFloat(maximumValue - minimumValue)
        let valuePerPoint = valueRange / frame.size.width
        value += Float((trackingHorizontalDelta * valuePerPoint) / valueDivisor)
        sendActionsForControlEvents(.ValueChanged)
        
        let leftPercentage = CGFloat(value - minimumValue) / valueRange
        let rightPercentage = CGFloat(maximumValue - value) / valueRange
        let leftOffset = frame.size.width * leftPercentage / (valueDivisor / 2.0)
        let rightOffset = frame.size.width * rightPercentage / (valueDivisor / 2.0)
        
        leftCaliper.frame.origin.x = frame.origin.x + (frame.size.width * leftPercentage) - leftOffset + 2
        leftCaliper.frame.origin.x = CGFloat(Int(leftCaliper.frame.origin.x))
        
        rightCaliper.frame.origin.x = frame.origin.x + frame.size.width - (frame.size.width * rightPercentage) + rightOffset - 4.0
        rightCaliper.frame.origin.x = CGFloat(Int(rightCaliper.frame.origin.x))
        
        leftTrack.frame.size.width = (frame.size.width * leftPercentage) - leftOffset + 1
        leftTrack.frame.size.width = CGFloat(Int(leftTrack.frame.size.width))
        
        rightTrack.frame.size.width = (frame.size.width * rightPercentage) - rightOffset + 1
        rightTrack.frame.size.width = CGFloat(Int(rightTrack.frame.size.width))
            
        rightTrack.frame.origin.x = frame.origin.x + frame.size.width - 2.0 - rightTrack.frame.size.width
        rightTrack.frame.origin.x = CGFloat(Int(rightTrack.frame.origin.x))
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        finishTracking()
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        finishTracking()
    }
    
    private func finishTracking() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.resetCaliperRects()
            self.calipersAndTracks.map({ $0.alpha = 0 })
        })
    }
}

