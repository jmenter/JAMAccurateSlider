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
    
    private let calipers:[UIView]
    private let tracks:[UIView]
    
    //MARK: - Setup Etc.
    
    required init(coder aDecoder: NSCoder) {
        calipers = [leftCaliper, rightCaliper]
        tracks = [leftTrack, rightTrack]
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        (tracks + calipers).map({ $0.alpha = 0 })
        (tracks + calipers).map({ self.superview?.addSubview($0) })
        
        dispatch_after(dispatch_time_t(0.0) , dispatch_get_main_queue()) {
            self.calipers.map({ self.styleCaliperView($0) })
            self.tracks.map({ self.styleTrackView($0) })
        }
        resetCaliperRects()
    }
    
    private func styleCaliperView(caliperView:UIView) {
        caliperView.backgroundColor = UIColor.whiteColor()
        caliperView.frame = CGRect(x: 0, y: 0, width: 2, height: 28)
        caliperView.layer.shadowColor = UIColor.blackColor().CGColor;
        caliperView.layer.shadowRadius = 1
        caliperView.layer.shadowOpacity = 0.5
        caliperView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        caliperView.layer.cornerRadius = 1
    }
    
    private func styleTrackView(trackView:UIView) {
        trackView.backgroundColor = (superview?.backgroundColor ?? UIColor.whiteColor()).colorWithAlphaComponent(0.75)
        trackView.layer.cornerRadius = 1
    }
    
    private func resetCaliperRects() {
        leftCaliper.frame.origin.x = frame.origin.x + 2
        leftCaliper.frame.origin.y = frame.origin.y + 1
        rightCaliper.frame.origin.x = frame.origin.x + frame.size.width - 4
        rightCaliper.frame.origin.y = frame.origin.y + 1
        
        leftTrack.frame = CGRect(x: frame.origin.x + trackRectForBounds(bounds).origin.x,
                                 y: frame.origin.y + trackRectForBounds(bounds).origin.y,
                             width: 2,
                            height: trackRectForBounds(bounds).size.height)
        
        rightTrack.frame = CGRect(x: frame.origin.x + frame.size.width - 2 - trackRectForBounds(bounds).origin.x,
                                  y: frame.origin.y + trackRectForBounds(bounds).origin.y,
                              width: 2,
                             height: trackRectForBounds(bounds).size.height)
    }
    
    private func finishTracking() {
        UIView.animateWithDuration(0.4, animations: {
            self.resetCaliperRects()
            (self.calipers + self.tracks).map({ $0.alpha = 0 })
        })
    }
    
    //MARK: - UIControl Touch Tracking
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        resetCaliperRects()
        UIView.animateWithDuration(0.2, animations: { (calipers + tracks).map({ $0.alpha = 1 }) })
        return super.beginTrackingWithTouch(touch, withEvent: event)
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let verticalTouchDelta = fabs(touch.locationInView(self).y - (frame.size.height / 2))
        let shouldTrackNormally = (verticalTouchDelta < frame.size.height * 2)
        if shouldTrackNormally {
            UIView.animateWithDuration(0.4, animations: { self.resetCaliperRects() })
            return super.continueTrackingWithTouch(touch, withEvent: event)
        }
        
        // Set more accurate value on the slider.
        let trackingHorizontalDelta = touch.locationInView(self).x - touch.previousLocationInView(self).x
        let valueDivisor = fabs(verticalTouchDelta / frame.size.height)
        let valueRange = CGFloat(maximumValue - minimumValue)
        let valuePerPoint = valueRange / frame.size.width
        value += Float((trackingHorizontalDelta * valuePerPoint) / valueDivisor)
        sendActionsForControlEvents(.ValueChanged)
        
        // Calculate caliper and track positions
        let leftPercentage = CGFloat(value - minimumValue) / valueRange
        let rightPercentage = CGFloat(maximumValue - value) / valueRange
        let leftOffset = frame.size.width * leftPercentage / (valueDivisor / 2)
        let rightOffset = frame.size.width * rightPercentage / (valueDivisor / 2)
        
        let leftCaliperOriginX = frame.origin.x + (frame.size.width * leftPercentage) - leftOffset + 2
        let rightCaliperOriginX = frame.origin.x + frame.size.width - (frame.size.width * rightPercentage) + rightOffset - 4
        let leftTrackWidth = (frame.size.width * leftPercentage) - leftOffset + 1
        let rightTrackWidth = (frame.size.width * rightPercentage) - rightOffset + 1
        let rightTrackOriginX = frame.origin.x + frame.size.width - 1 - rightTrackWidth
        
        // Apple's UI elements always snap to integer point values so we should as well.
        leftCaliper.frame.origin.x = CGFloat(Int(leftCaliperOriginX))
        rightCaliper.frame.origin.x = CGFloat(Int(rightCaliperOriginX))
        leftTrack.frame.size.width = CGFloat(Int(leftTrackWidth))
        rightTrack.frame.size.width = CGFloat(Int(rightTrackWidth))
        rightTrack.frame.origin.x = CGFloat(Int(rightTrackOriginX))
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        finishTracking()
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        finishTracking()
    }
}

