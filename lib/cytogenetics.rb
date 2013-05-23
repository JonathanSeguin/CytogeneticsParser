require_relative 'cytogenetics/aberration'
require_relative 'cytogenetics/breakpoint'
require_relative 'cytogenetics/chromosome'
require_relative 'cytogenetics/fragment'
require_relative 'cytogenetics/karyotype'

require_relative 'cytogenetics/aberrations/translocation'
require_relative 'cytogenetics/aberrations/derivative'
require_relative 'cytogenetics/aberrations/basic_aberrations'
require_relative 'cytogenetics/aberrations/ploidy_aberrations'

require_relative 'cytogenetics/chromosomes/dicentric_chromosome'
require_relative 'cytogenetics/chromosomes/double_minute_chromosome'
require_relative 'cytogenetics/chromosomes/ring'

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
  end


  def self.bands
    return @band_reader
  end


  def self.karyotype(*args)
    raise ArgumentError, "Missing argument, karyotype string required as the first parameter." unless (args[0] and args[0].length > 0)
    kary_str = args[0]

    cdir = File.dirname(__FILE__).split("/")
    cdir[-1] = "resources"
    cdir = cdir.join("/")
    (args[1].nil?)? (band_file = "#{cdir}/HsBands.txt"): (band_file = args[1])

    @band_reader = BandReader.new(band_file, :chr => 0, :band => 1)
    return Karyotype.new(kary_str)
  end

  def self.classify_aberration(abr)
    return Aberration.classify_aberration(abr)
  end

  class KaryotypeError < StandardError
  end

  class StructureError < KaryotypeError
    def initialize(msg = nil)
      text = "Karyotype string is incorrectly structured"
      text = "#{text}: #{msg}" if msg
      super(text)
    end
  end

  class BandDefinitionError < KaryotypeError
    def initialize(msg = nil)
      text = "Bands undefined or incorrectly defined"
      text = "#{text}: #{msg}" if msg
      super(text)
    end
  end

end