require_relative 'cytogenetics/aberration'
require_relative 'cytogenetics/breakpoint'
require_relative 'cytogenetics/chromosome'
require_relative 'cytogenetics/fragment'
require_relative 'cytogenetics/karyotype'

require_relative 'cytogenetics/aberrations/translocation'
require_relative 'cytogenetics/aberrations/dicentric_chromosome'
require_relative 'cytogenetics/aberrations/derivative'
require_relative 'cytogenetics/aberrations/double_minute_chromosome'

require_relative 'cytogenetics/aberrations/basic_aberrations'
require_relative 'cytogenetics/aberrations/ploidy_aberrations'

require_relative 'cytogenetics/utils/karyotype_reader'
require_relative 'cytogenetics/utils/band_reader'

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

  def self.classify_aberration(abr)
    return Aberration.classify_aberration(abr)
  end


  class StructureError < StandardError
  end

  class KaryotypeError < StandardError
  end

end