###
## BlendControls manages the three different blending styles.
## One can decide for either 'normal' (e.g. next frame completely
## replaces the previous one) or 'paintOver' (new frame is painted
## over the previous one, meaning that the previous frame shows through
## the transparent bits of the new frame) or 'motionBlur'
## (previous frame is shown faintly below the current one so to give
## a vague effect of motion blur).
###

class BlendControls
  
  previousanimationStyleValue: 0
  animationStyleValue: 0
  # Just an object to hold the animation style variables
  animationStyles: {
    normal: 0,
    paintOver: 1,
    motionBlur: 2
  }
  # Used for setting how much blending there is between frames
  blendAmount: 0
  # Tweakable parameter for mixing of motionBlur
  motionBlurAmount: 0.7
  previousMotionBlurAmount: 0.7
  
  constructor: (@threeJsSystem) ->

  addToScope: (scope) ->
    scope.addVariable('normal',         @animationStyles.normal)
    scope.addVariable('paintOver',      @animationStyles.paintOver)
    scope.addVariable('motionBlur',     @animationStyles.motionBlur)
    scope.addFunction('animationStyle', (a, b) => @animationStyle(a, b))

  animationStyle: (a, b) ->
    # turns out when you type normal that the first two letters "no"
    # are sent as "false"
    return  if a is false or not a?
    @animationStyleValue = a
    # using the same style of check because I don't know coffeescript well enough to do something sensible / idiomatic
    # but the bigger issue is that I seem to be getting b === undefined
    return  if b is false or not b?
    @motionBlurAmount = b ##nb: this is now generating "return this.motionBlurAmount = b"...

  animationStyleUpdateIfChanged: ->
    # Animation Style hasn't changed so we don't need to do anything
    return if @animationStyleValue is @previousanimationStyleValue and @motionBlurAmount is @previousMotionBlurAmount
    @previousanimationStyleValue = @animationStyleValue
    @previousMotionBlurAmount = @motionBlurAmount

    switch @animationStyleValue
        when @animationStyles.paintOver
            @threeJsSystem.effectBlend.uniforms.mixRatio.value = 1.0 
        when @animationStyles.motionBlur
            @threeJsSystem.effectBlend.uniforms.mixRatio.value = @motionBlurAmount
        when @animationStyles.normal
            @threeJsSystem.effectBlend.uniforms.mixRatio.value = 0
        else
            @threeJsSystem.effectBlend.uniforms.mixRatio.value = 0


module.exports = BlendControls

