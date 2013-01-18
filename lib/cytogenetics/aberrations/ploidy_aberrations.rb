require_relative '../aberration'

module Cytogenetics

  module ChromosomeAberrations

    ## CHROMOSOME GAIN
    class ChromosomeGain < Aberration
      @kt = 'gain'
      @rx = /^\+(\d+|X|Y)$/

      def initialize(str)
        config_logging()
        @abr = str.sub("+", "")
        @breakpoints = []
      end
    end

    ## CHROMOSOME LOSS
    class ChromosomeLoss < Aberration
      @kt = 'loss'
      @rx = /^-(\d+|X|Y)$/

      def initialize(str)
        config_logging()
        @abr = str.sub("-", "")
        @breakpoints = []
      end
    end

  end
end

