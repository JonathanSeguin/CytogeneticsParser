require_relative '../aberration'
require_relative 'ring'

module Cytogenetics

  module ChromosomeAberrations

    class DoubleMinuteChromosome < Aberration
      @kt = 'dmin'
      @rx = /^(\d+(~\d+)?)dmin\((\d+|X|Y)\)/
      @chr_pos = -1

      # No breakpoints in a dmin chromosome, but I wrote the Aberration object poorly due to assumptions that I only cared
      # about breakpoints. The method is a bit overloaded now but would require cleaning up the Karyotype class so...
      def get_breakpoints

        # fragments may also not be the best way to list these bits of chromosome
        match = @abr.match(self.class.regex)
        fragments = match.captures.first.split("~")
        (fragments.first..fragments.last).each { |i| (@dmin ||= []) << Ring.new( match.captures[-1] )}
      end




    end

  end

end
