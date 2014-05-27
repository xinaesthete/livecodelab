###
## Takes care of all matrix-related commands.
###

isFunction = (functionToCheck) ->
  getType = {}
  functionToCheck and getType.toString.call(functionToCheck) is "[object Function]"

define () ->

  class MatrixCommands

    matrixStack: []

    constructor: (@liveCodeLabCore_three, @liveCodeLabCoreInstance) ->
      @worldMatrix = new @liveCodeLabCore_three.Matrix4()

    addToScope: (scope) ->

      scope.add('pushMatrix',  () => @pushMatrix())
      scope.add('popMatrix',   () => @popMatrix())
      scope.add('resetMatrix', () => @resetMatrix())
      scope.add('move',        (a,b,c,d) => @move(a,b,c,d))
      scope.add('rotate',      (a,b,c,d) => @rotate(a,b,c,d))
      scope.add('scale',       (a,b,c,d) => @scale(a,b,c,d))

    getWorldMatrix: ->
      @worldMatrix

    resetMatrixStack: ->
      @matrixStack = []
      @worldMatrix.identity()

    pushMatrix: ->
      if @liveCodeLabCoreInstance.animationLoop.noDrawFrame
        return

      @matrixStack.push @worldMatrix
      @worldMatrix = (new @liveCodeLabCore_three.Matrix4()).copy(@worldMatrix)

    popMatrix: ->
      if @liveCodeLabCoreInstance.animationLoop.noDrawFrame
        return

      if @matrixStack.length
        @worldMatrix = @matrixStack.pop()
      else
        @worldMatrix.identity()

    resetMatrix: ->
      if @liveCodeLabCoreInstance.animationLoop.noDrawFrame
        return

      @worldMatrix.identity()

    move: (a, b, c = 0, d = null) ->
      if @liveCodeLabCoreInstance.animationLoop.noDrawFrame
        return

      appendedFunction = undefined

      if typeof a isnt "number"
        if isFunction a then appendedFunction = a
        a = Math.sin(@liveCodeLabCoreInstance.timeKeeper.beat() / 2 * Math.PI)
        b = Math.cos(@liveCodeLabCoreInstance.timeKeeper.beat() / 2 * Math.PI)
        c = a
      else if typeof b isnt "number"
        if isFunction b then appendedFunction = b
        b = a
        c = a
      else if typeof c isnt "number"
        if isFunction c then appendedFunction = c
        c = 0
      else if isFunction d
        appendedFunction = d

      @pushMatrix() if appendedFunction? 
      @worldMatrix.multiply(new @liveCodeLabCore_three.Matrix4().makeTranslation(a, b, c))
      if appendedFunction?
        appendedFunction()
        @popMatrix()

    rotate: (a, b, c = 0, d = null) ->
      if @liveCodeLabCoreInstance.animationLoop.noDrawFrame
        return

      appendedFunction = undefined

      if typeof a isnt "number"
        if isFunction a then appendedFunction = a
        a = @liveCodeLabCoreInstance.timeKeeper.beat() / 4 * Math.PI
        b = a
        c = 0
      else if typeof b isnt "number"
        if isFunction b then appendedFunction = b
        b = a
        c = a
      else if typeof c isnt "number"
        if isFunction c then appendedFunction = c
        c = 0
      else if isFunction d
        appendedFunction = d

      @pushMatrix() if appendedFunction?
      @worldMatrix.multiply(new @liveCodeLabCore_three.Matrix4().makeRotationFromEuler(new @liveCodeLabCore_three.Euler(a,b,c,'XYZ')))
      if appendedFunction?
        appendedFunction()
        @popMatrix()

    scale: (a, b, c = 1, d = null) ->
      if @liveCodeLabCoreInstance.animationLoop.noDrawFrame
        return

      appendedFunction = undefined

      if typeof a isnt "number"
        if isFunction a then appendedFunction = a
        a = 0.5 + @liveCodeLabCoreInstance.timeKeeper.pulse()
        b = a
        c = a
      else if typeof b isnt "number"
        if isFunction b then appendedFunction = b
        b = a
        c = a
      else if typeof c isnt "number"
        if isFunction c then appendedFunction = c
        c = 1
      else if isFunction d
        appendedFunction = d
      
      @pushMatrix() if appendedFunction? 

      # odd things happen setting scale to zero
      a = 0.000000001  if a > -0.000000001 and a < 0.000000001
      b = 0.000000001  if b > -0.000000001 and b < 0.000000001
      c = 0.000000001  if c > -0.000000001 and c < 0.000000001

      @worldMatrix.multiply(new @liveCodeLabCore_three.Matrix4().makeScale(a, b, c))
      if appendedFunction?
        appendedFunction()
        @popMatrix()

  MatrixCommands

