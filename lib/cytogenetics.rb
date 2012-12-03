require 'cytogenetics/aberration'
require 'cytogenetics/breakpoint'
require 'cytogenetics/chromosome'
require 'cytogenetics/chromosome_aberrations'
require 'cytogenetics/fragment'
require 'cytogenetics/karyotype'
require 'cytogenetics/karyotype_error'


require 'cytogenetics/utils/karyotype_reader'
require 'cytogenetics/utils/band_reader'

require 'yaml'
require 'logger'

module Cytogenetics

  class << self
    def logger=(log)
      @clog = log
    end

    def logger
      unless @clog
        @clog = Logger.new(STDOUT)
        @clog.level = Logger::FATAL
      end
      @clog
    end

    #def haploid=(hp)
    #  @sp_ploidy=hp
    #end
    #
    #def haploid
    #  unless @sp_ploidy
    #
    #  end
    #end

  end



  def self.karyotype(kary_str)
    return Karyotype.new(kary_str)
  end

end