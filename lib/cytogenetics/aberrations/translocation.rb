require 'yaml'
require_relative '../aberration'

module Cytogenetics

  module ChromosomeAberrations

    ## TRANSLOCATION ... this is typically a subset of Derivative chromosomes, but have seen it on it's own
    class Translocation < Aberration
      @kt = 'trans'
      @rx = /^t\((\d+|X|Y)[;|:](\d+|X|Y)\)/
      @ex = 2

      ## TWo ways of defining translocations:
      ## 1)  t(1;3)(p31;p13)
      def get_breakpoints
        chr_i = find_chr(@abr)
        band_i = find_bands(@abr, chr_i[:end_index])
        unless band_i
          @log.warn("No bands defined in #{@abr}")
        else
          chr_i[:chr].each_with_index do |c, i|
            @breakpoints << Breakpoint.new(c, band_i[:bands][i], 'trans')
          end
        end
      end
    end
  end
end