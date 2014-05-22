define () ->
  class MutatorCommands
    currentGenes: {}
    geneDeltas: {}
    geneDefs: {}

    addToScope: (scope) ->
      scope.add('gene',      (name, min, max) => @gene(name, min, max))
      scope.add('g',         (name, min, max) => @gene(name, min, max))

    gene: (name, min=0, max=1) ->
      # what do we know about the gene with this name?
      # have we seen it before, or is it brand new?
      # if it's new, we should choose a value and delta for it
      # we're not going to be too bright about name clashes for now:
      # if we've seen the name before, we'll make sure the definition matches that just given...

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

  MutatorCommands
