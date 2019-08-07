JAMAccurateSlider
===========

A UISlider subclass that enables much more accurate value selection.

![example image](https://raw.githubusercontent.com/jmenter/JAMAccurateSlider/master/example.png "JAMAccurateSlider Example Image")

JAMAccurateSlider is a drop-in replacement for UISlider. It behaves exactly the same as UISlider with the following awesome differences:

1. When the user begins tracking, two small "calipers" appear at the extents of the track.
2. When the user tracks their finger up (or down) past a certain threshold (~twice the height of the slider), the calipers move in towards the thumb and the thumb (and corresponding slider value) begins to move more slowly and accurately.
3. The calipers are a visual indication of how accurate the slider is, and is a great way for users to intuitively grasp the interaction mechanism.
4. The further the user moves their finger vertically from the slider, the greater the possibility of accuracy.

This behavior is completely automatic. There is nothing to configure. We think you'll love it.
