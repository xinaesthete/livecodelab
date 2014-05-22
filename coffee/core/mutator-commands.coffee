define () ->
  class MutatorCommands
    currentGenes: {}
    geneDeltas: {}
    geneDefs: {}
    # keep track of names that have already been called, so that eg if a gene is called multiple times in a loop
    # it can detect this and not go along delta
    geneNamesThisFrame: []

    addToScope: (scope) ->
      scope.add('gene',      (name, min, max) => @gene(name, min, max))
      scope.add('g',         (name, min, max) => @gene(name, min, max))
      scope.add('mutateDir', (delta) => @mutateDir(delta))

    resetFrame: ->
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

      old = @currentGenes[name]
      d = @geneDeltas[name]
      if old + d > max or old + d < min
        d = @geneDeltas[name] *= -1
      @currentGenes[name] += d


      return @currentGenes[name]

    mutateDir: (delta=1) ->
      mutateGDir(n, delta) for n, v in @geneDeltas

    mutateGDir: (name, delta=1) ->
      old = @geneDeltas[name]
      gd = @geneDefs[name]
      range = gd.max - gd.min
      @geneDeltas[name] += delta * random(-range, range) / 1000

  MutatorCommands
