/*
 
 Copyright (c) 2016 Jeff Menter
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

import UIKit

class AccurateSlider: UISlider {
    
    fileprivate let leftCaliper = UIView()
    fileprivate let rightCaliper = UIView()
    fileprivate let leftTrack = UIView()
    fileprivate let rightTrack = UIView()
    fileprivate var trackRect = CGRect.zero
    fileprivate let calipers:[UIView]
    fileprivate let tracks:[UIView]
    
    fileprivate let fadeInDuration:TimeInterval = 0.2
    fileprivate let fadeOutDuration:TimeInterval = 0.4
    
    //MARK: - Setup Etc.
    
    required init?(coder aDecoder: NSCoder) {
        calipers = [leftCaliper, rightCaliper]
        tracks = [leftTrack, rightTrack]
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        trackRect = trackRect(forBounds:bounds)
        (tracks + calipers).forEach {$0.alpha = 0; self.superview?.addSubview($0)}
        resetCaliperRects()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.calipers.forEach {self.styleCaliperView($0) }
            self.tracks.forEach {self.styleTrackView($0) }
        }
    }
    
    fileprivate func styleCaliperView(_ caliperView:UIView) {
        caliperView.backgroundColor = UIColor.white
        caliperView.frame = CGRect(x: 0, y: 0, width: 2, height: 28)
        caliperView.layer.shadowColor = UIColor.black.cgColor;
        caliperView.layer.shadowRadius = 1
        caliperView.layer.shadowOpacity = 0.5
        caliperView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        caliperView.layer.cornerRadius = 1
    }
    
    fileprivate func styleTrackView(_ trackView:UIView) {
        trackView.backgroundColor = (superview?.backgroundColor ?? UIColor.white).withAlphaComponent(0.75)
        trackView.layer.cornerRadius = 1
    }
    
    fileprivate func resetCaliperRects() {
        leftCaliper.frame.origin.x = frame.origin.x + 2
        leftCaliper.frame.origin.y = frame.origin.y + 1
        rightCaliper.frame.origin.x = frame.origin.x + frame.size.width - 4
        rightCaliper.frame.origin.y = frame.origin.y + 1
        leftTrack.frame = CGRect(x: frame.origin.x + trackRect.origin.x, y: frame.origin.y + trackRect.origin.y, width: 2, height: trackRect.size.height)
        rightTrack.frame = CGRect(x: frame.origin.x + frame.size.width - 2 - trackRect.origin.x, y: frame.origin.y + trackRect.origin.y, width: 2, height: trackRect.size.height)
    }
    
    fileprivate func finishTracking() {
        UIView.animate(withDuration: fadeOutDuration, animations: {
            self.resetCaliperRects()
            (self.calipers + self.tracks).forEach { $0.alpha = 0 }
        })
    }
    
    //MARK: - UIControl Touch Tracking
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        resetCaliperRects()
        UIView.animate(withDuration: fadeInDuration, animations: { (self.calipers + self.tracks).forEach{ $0.alpha = 1 } })
        return super.beginTracking(touch, with: event)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let verticalTouchDelta = fabs(touch.location(in: self).y - (frame.size.height / 2))
        let shouldTrackNormally = (verticalTouchDelta < frame.size.height * 2)
        if shouldTrackNormally {
            UIView.animate(withDuration: fadeOutDuration, animations: { self.resetCaliperRects() })
            return super.continueTracking(touch, with: event)
        }
        
        let trackingHorizontalDelta = touch.location(in: self).x - touch.previousLocation(in: self).x
        let valueDivisor = fabs(verticalTouchDelta / frame.size.height)
        let valueRange = CGFloat(maximumValue - minimumValue)
        let valuePerPoint = valueRange / frame.size.width
        value += Float((trackingHorizontalDelta * valuePerPoint) / valueDivisor)
        sendActions(for: .valueChanged)
        
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
        leftCaliper.frame.origin.x = leftCaliperOriginX.intify()
        rightCaliper.frame.origin.x = rightCaliperOriginX.intify()
        leftTrack.frame.size.width = leftTrackWidth.intify()
        rightTrack.frame.size.width = rightTrackWidth.intify()
        rightTrack.frame.origin.x = rightTrackOriginX.intify()
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        finishTracking()
    }
    
    override func cancelTracking(with event: UIEvent?) {
        finishTracking()
    }
}

extension CGFloat {
    func intify() -> CGFloat {
        return CGFloat(Int(self))
    }
}
