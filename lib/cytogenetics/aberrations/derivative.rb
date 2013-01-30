require_relative '../aberration'

module Cytogenetics

  module ChromosomeAberrations

    ## DERIVATIVE
    # Derivative chromosomes are indicated with der(9)... the translation is that the derivative is added to the ploidy
    # and then aberrations are made such as translocations or band deletions.
    class Derivative < Aberration
      @kt = 'der'
      @rx = /^der\((\d+|X|Y)\)/

      def get_breakpoints
        @aberrations = []

        ab_objs = Aberration.aberration_objs

        chr_i = find_chr(@abr)
        derivative_abr = @abr[chr_i[:end_index]+1..@abr.length]

        # separate different abnormalities within the derivative chromosome and clean it up to make it parseable
        abnormalities = derivative_abr.scan(/([^\(\)]+\(([^\(\)]|\)\()*\))/).collect { |a| a[0] }

        trans_bps = []
        abnormalities.each do |abn|
          abrclass = Aberration.classify_aberration(abn)

          if abrclass.to_s.eql? 'unk' # not dealing with unknowns
            @log.warn("Cannot handle #{abn}, incorrect format.")
            next
          end

          # special handling because translocations are written as a sliding window
          # translocations should also only every have 2 breakpoints...
          if abrclass.to_s.eql? ChromosomeAberrations::Translocation.type
            trans = ChromosomeAberrations::Translocation.new(abn)
            unless trans.breakpoints.length < 2 # translocation should have at least 2 breakpoints
              trans_bps << trans.breakpoints
              @breakpoints << trans.breakpoints
            end
          else
            ab_obj = ab_objs[abrclass].new(abn)
            if ab_obj.breakpoints.length > 0
              @aberrations << ab_obj
              @breakpoints << ab_obj.breakpoints
            end
          end
        end
        trans_bps.delete_if { |c| c.empty? }
        add_fragments(trans_bps.flatten!) if trans_bps.length > 0
      end

      :private
      # have to reorder the array and then turn Breakpoints into fragments
      def add_fragments(tbp_list)
        sorted = []
        tbp_list.each_with_index do |e, i|
          if i <= 1
            sorted << Breakpoint.new(e.chr, "#{e.arm}ter") if i.eql? 0
            sorted << e
          elsif i%2 == 0
            sorted << tbp_list[i+1]
            sorted << tbp_list[i]
          end
        end
        sorted << Breakpoint.new(sorted[-1].chr, "#{sorted[-1].arm}ter")
        sorted.each_slice(2).to_a.each do |pair|
          begin
            @fragments << Fragment.new(pair[0], pair[1])
          rescue ArgumentError => ae
            @log.warn("#{ae.message} Skipping fragment: #{pair.inspect}.")
          end
        end
      end
    end
  end
end
