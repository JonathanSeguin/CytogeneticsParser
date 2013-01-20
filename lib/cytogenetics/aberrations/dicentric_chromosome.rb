require 'yaml'
require_relative '../aberration'

module Cytogenetics

  module ChromosomeAberrations


    ## ROBERTSONIAN chromsome/translocation is the same as a dicentric chromosome
    ## dic(1;19)(q12;q13) This means that the chromosome is 1pter->1q12->19q13->19pter
    ## This one is a little more difficult, see in CyDas.org  It looks like the chromosome duplicates itself
    ## from 13q11(centromere)->13q32->13q11(centromere)  but I'm not sure how q14 fits and cydas shows a fragment of
    ## p arm as well

    class DicentricChromosome < Aberration
      @kt = 'dic'
      @rx = /^dic\((\d+|X|Y)[;|:](\d+|X|Y)\)/

      #def get_breakpoints
      #  chr_i = find_chr(@abr)
      #  band_i = find_bands(@abr, chr_i[:end_index])
      #  chr_i[:chr].each_with_index do |c, i|
      #    @breakpoints << Breakpoint.new(c, band_i[:bands][i], 'dic')
      #  end
      #  # TODO am not sure how the dic rearrangment works, see this in CyDas dic(13;13)(q14;q32)
      #  #@fragments << Fragment.new( Breakpoint.new(@breakpoints[0].chr, "pter"), @breakpoints[0])
      #  #@fragments << Fragment.new( @breakpoints[1], Breakpoint.new(@breakpoints[1].chr, "#{@breakpoints[1].arm}ter"))
      #end
    end
  end
end
