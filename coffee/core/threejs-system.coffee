###
## Sets up canvas or webgl Threejs renderer based on browser capabilities
## and flags passed in the constructor. Sets up all the post-filtering steps.
###

define [
], (
) ->

  class ThreeJsSystem

    @isWebGLUsed: false
    @composer: {}
    @feedbackMap: undefined
    constructor: ( \
      Detector, \
        THREEx, \
        @blendedThreeJsSceneCanvas, \
        @forceCanvasRenderer, \
        testMode, \
        liveCodeLabCore_three ) ->

      # if we've not been passed a canvas, then create a new one and make it
      # as big as the browser window content.
      unless @blendedThreeJsSceneCanvas
        @blendedThreeJsSceneCanvas = document.createElement("canvas")
        @blendedThreeJsSceneCanvas.width = window.innerWidth
        @blendedThreeJsSceneCanvas.height = window.innerHeight


      if not @forceCanvasRenderer and Detector.webgl
        # Webgl init.
        # We allow for a bigger ball detail.
        # Also the WebGL context allows us to use the Three JS composer and the
        # postprocessing effects, which use shaders.
        @ballDefaultDetLevel = 16
        @blendedThreeJsSceneCanvasContext =
          @blendedThreeJsSceneCanvas.getContext("experimental-webgl")

        # see http://mrdoob.github.com/three.js/docs/53/#Reference/Renderers/WebGLRenderer
        @renderer = new liveCodeLabCore_three.WebGLRenderer(
          canvas: @blendedThreeJsSceneCanvas
          preserveDrawingBuffer: testMode # to allow screenshot
          antialias: false
          premultipliedAlpha: false
        )
        @isWebGLUsed = true

      else
        # Canvas init.
        # Note that the canvas init requires two extra canvases in
        # order to achieve the motion blur (as we need to keep the
        # previous frame). Basically we have to do manually what the
        # WebGL solution achieves through the Three.js composer
        # and postprocessing/shaders.
        @ballDefaultDetLevel = 6
        @currentFrameThreeJsSceneCanvas = document.createElement("canvas")

        # some shorthands
        currentFrameThreeJsSceneCanvas = @currentFrameThreeJsSceneCanvas

        currentFrameThreeJsSceneCanvas.width = @blendedThreeJsSceneCanvas.width
        currentFrameThreeJsSceneCanvas.height = @blendedThreeJsSceneCanvas.height

        @currentFrameThreeJsSceneCanvasContext =
          currentFrameThreeJsSceneCanvas.getContext("2d")

        @previousFrameThreeJSSceneRenderForBlendingCanvas =
          document.createElement("canvas")
        # some shorthands
        previousFrameThreeJSSceneRenderForBlendingCanvas =
          @previousFrameThreeJSSceneRenderForBlendingCanvas
        previousFrameThreeJSSceneRenderForBlendingCanvas.width =
          @blendedThreeJsSceneCanvas.width
        previousFrameThreeJSSceneRenderForBlendingCanvas.height =
          @blendedThreeJsSceneCanvas.height

        @previousFrameThreeJSSceneRenderForBlendingCanvasContext =
          @previousFrameThreeJSSceneRenderForBlendingCanvas.getContext("2d")
        @blendedThreeJsSceneCanvasContext =
          @blendedThreeJsSceneCanvas.getContext("2d")

        # see http://mrdoob.github.com/three.js/docs/53/#Reference/Renderers/CanvasRenderer
        @renderer = new liveCodeLabCore_three.CanvasRenderer(
          canvas: currentFrameThreeJsSceneCanvas
          antialias: true # to get smoother output
          preserveDrawingBuffer: testMode # to allow screenshot
          # todo figure out why this works. this parameter shouldn't
          # be necessary, as per https://github.com/mrdoob/three.js/issues/2833 and
          # https://github.com/mrdoob/three.js/releases this parameter
          # should not be needed. If we don't pass it, the canvas is all off, the
          # unity box is painted centerd in the bottom right corner
          devicePixelRatio: 1
        )

      @renderer.setSize @blendedThreeJsSceneCanvas.width, \
        @blendedThreeJsSceneCanvas.height
      @scene = new liveCodeLabCore_three.Scene()
      @scene.matrixAutoUpdate = false

      # put a camera in the scene
      @camera = new liveCodeLabCore_three.PerspectiveCamera(35, \
        @blendedThreeJsSceneCanvas.width / \
        @blendedThreeJsSceneCanvas.height, 1, 10000)
      @camera.position.set 0, 0, 5
      @scene.add @camera

      # transparently support window resize
      THREEx.WindowResize.bind @renderer, @camera

      if @isWebGLUsed
        renderTargetParameters = undefined
        renderTarget = undefined
        feedbackSaveTarget = undefined
        effectSaveTarget = undefined
        fxaaPass = undefined
        feedbackSavePass = undefined
        screenPass = undefined
        renderModel = undefined
        renderTargetParameters =
          format: liveCodeLabCore_three.RGBAFormat
          stencilBuffer: true
          generateMipmaps: false
          minFilter: liveCodeLabCore_three.LinearFilter

        # these are the three buffers.
        # TODO: support for oversampling (nb, to show real pixels on rMBP, canvas itself might need changing)
        renderTarget = new liveCodeLabCore_three.WebGLRenderTarget(
          @blendedThreeJsSceneCanvas.width,
          @blendedThreeJsSceneCanvas.height,
          renderTargetParameters
        )
        # renderTarget.generateMipmaps = false
        renderTargetParameters.depthBuffer = false
        feedbackSaveTarget = new liveCodeLabCore_three.WebGLRenderTarget(
            @blendedThreeJsSceneCanvas.width,
            @blendedThreeJsSceneCanvas.height,
            renderTargetParameters
        )
        feedbackSaveTarget.clear = false
        #feedbackSaveTarget.renderTarget.generateMipmaps = false
        feedbackSaveTarget.xxtag = "feedback target"
        @feedbackMap = feedbackSaveTarget

        effectSaveTarget = new liveCodeLabCore_three.SavePass(
          new liveCodeLabCore_three.WebGLRenderTarget(
            @blendedThreeJsSceneCanvas.width,
            @blendedThreeJsSceneCanvas.height,
            renderTargetParameters
          )
        )
        effectSaveTarget.clear = false
        effectSaveTarget.generateMipmaps = false


        # Uncomment the three lines containing "fxaaPass" below to try a fast
        # antialiasing filter. Commented below because of two reasons:
        # a) it's slow
        # b) it blends in some black pixels, so it only looks good
        #     in dark backgrounds
        # The problem of blending with black pixels is the same problem of the
        # motionBlur leaving a black trail - tracked in github with
        # https://github.com/davidedc/livecodelab/issues/22

        #fxaaPass = new liveCodeLabCore_three.ShaderPass(liveCodeLabCore_three.ShaderExtras.fxaa);
        #fxaaPass.uniforms.resolution.value.set(1 / window.innerWidth, 1 / window.innerHeight);

        # this is the place where everything is mixed together
        @composer = new liveCodeLabCore_three.EffectComposer(
          @renderer, renderTarget)

        feedbackSavePass = new liveCodeLabCore_three.SavePass(feedbackSaveTarget)

        # this is the effect that blends two buffers together
        # for motion blur.
        # it's going to blend the previous buffer that went to
        # screen and the new rendered buffer
        @effectBlend = new liveCodeLabCore_three.ShaderPass(
          liveCodeLabCore_three.ShaderExtras.blend, "tDiffuse1")
        @effectBlend.uniforms.tDiffuse2.value = effectSaveTarget.renderTarget
        @effectBlend.uniforms.mixRatio.value = 0

        screenPass = new liveCodeLabCore_three.ShaderPass(
          liveCodeLabCore_three.ShaderExtras.screen)

        renderModel = new liveCodeLabCore_three.RenderPass(
          @scene, @camera)


        # first thing, render the model
        @composer.addPass renderModel
        # then apply some fake post-processed antialiasing
        #@composer.addPass(fxaaPass);
        # save result for use in video feedback materials, before the other save for motion blur
        @composer.addPass feedbackSavePass
        # then blend using the previously saved buffer and a mixRatio
        @composer.addPass @effectBlend
        # the result is saved in a copy: effectSaveTarget.renderTarget
        @composer.addPass effectSaveTarget
        # last pass is the one that is put to screen
        @composer.addPass screenPass
        screenPass.renderToScreen = true

  ThreeJsSystem
