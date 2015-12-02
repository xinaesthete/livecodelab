define () ->
  class MutatorCommands
    animSpeed: 1
    currentGenes: {}
    geneDeltas: {}
    geneDefs: {}
    # keep track of names that have already been called, so that eg if a gene is called multiple times in a loop
    # it can detect this and not go along delta
    geneNamesThisFrame: []
    geneNamesLastFrame: []
    gui: new dat.GUI();
    
    addToScope: (scope) ->
      scope.add('gene',      (name, min, max) => @gene(name, min, max))
      scope.add('g',         (name, min, max) => @gene(name, min, max))
      scope.add('animSpeed', (a) => @setAnimSpeed(a))
      scope.add('mutateDir', (delta) => @mutateDir(delta))
      scope.add('mutate',    (delta) => @mutate(delta))

    resetFrame: ->
      $('.dg').css('z-index', 10)
      @geneNamesLastFrame = @geneNamesThisFrame
      @geneNamesThisFrame = []

    gene: (name, min=0, max=1) ->
      # what do we know about the gene with this name?
      # have we seen it before, or is it brand new?
      # if it's new, we should choose a value and delta for it
      # we're not going to be too bright about name clashes for now:
      # if we've seen the name before, we'll make sure the definition matches that just given...
      # if we've seen the name already in this frame, then we should just return the value, not increment or check ranges etc.
      if name in @geneNamesThisFrame
        return @currentGenes[name]
      @geneNamesThisFrame.push name
      gd = @geneDefs[name]
      if !gd or gd.min isnt min or gd.max isnt max
        gd = @geneDefs[name] = {min: min, max: max}
        @currentGenes[name] = random(min, max)
        range = max-min
        @geneDeltas[name] = random(-range, range) / 100
        @gui.add(@currentGenes, name, min, max).listen()

      old = @currentGenes[name]
      d = @geneDeltas[name] * @animSpeed
      if old + d > max or old + d < min
        d *= -1
        @geneDeltas[name] *= -1
      @currentGenes[name] += d


      return @currentGenes[name]

    setAnimSpeed: (v=1) ->
      v = 1 if typeof v isnt 'number'
      @animSpeed = v

    mutate: (delta=0.1) ->
      delta = 0.1 if typeof delta isnt 'number'
      @mutateG(n, delta) for n in @geneNamesLastFrame

    mutateG: (name, delta=0.1) ->
      delta = Math.min(Math.max(delta, 0), 1)
      gd = @geneDefs[name]
      old = @currentGenes[name]
      v = random(gd.min, gd.max)
      @currentGenes[name] = lerp(@currentGenes[name], v, delta)
      return true

    mutateDir: (delta=0.1) ->
      delta = 0.1 if typeof delta isnt 'number'
      @mutateGDir(n, delta) for n in @geneNamesLastFrame

    mutateGDir: (name, delta=0.1) ->
      delta = Math.min(Math.max(delta, 0), 1)
      old = @geneDeltas[name]
      gd = @geneDefs[name]
      range = gd.max - gd.min
      v = random(-range, range) / 100
      @geneDeltas[name] = lerp(@geneDeltas[name], v, delta)
      return true

  MutatorCommands
