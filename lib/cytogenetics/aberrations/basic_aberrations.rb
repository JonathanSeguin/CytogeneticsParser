require_relative '../aberration'

module Cytogenetics

  module ChromosomeAberrations

    ## INVERSION
    class Inversion < Aberration
      @kt = 'inv'
      @rx = /^inv\((\d+|X|Y)\)/
    end

    ## DUPLICATION
    class Duplication < Aberration
      @kt = 'dup'
      @rx = /^dup\((\d+|X|Y)\)/
    end

    ## INSERTION
    class Insertion < Aberration
      @kt = 'ins'
      @rx = /^ins\((\d+|X|Y)\)/
    end

    ## DELETION
    class Deletion < Aberration
      @kt = 'del'
      @rx = /^del\((\d+|X|Y)\)/
    end

    ## ADD (addition of unknown material)
    class Addition < Aberration
      @kt = 'add'
      @rx = /^add\((\d+|X|Y)\)/
    end

    ## ISOCHROMOSOME
    class Isochromosome < Aberration
      @kt = 'iso'
      @rx = /^i\((\d+|X|Y)\)/
    end

    ## FRAGMENT
    class ChromosomeFragment < Aberration
      @kt = 'frag'
      @rx = /^frag\((\d+|X|Y)\)/
    end

    ## RING  ## TODO figure out the right regex for this
    #class RingChromosome < Aberration
    #  @kt = 'ring'
    #  @rx = /^r\(/
    #end

    ## ROBERTSONIAN
    #class Robertsonian < Aberration
    #  @kt = 'rob'
    #  @rx = /^rob\(/
    #end

  end
end
