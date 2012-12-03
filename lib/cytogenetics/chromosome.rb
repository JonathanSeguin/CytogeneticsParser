require 'cytogenetics/utils/band_reader'

File.expand_path '../../resources', File.dirname(__FILE__)


module Cytogenetics

  class Chromosome
    include BandReader

    class<<self
      attr_accessor :normal_bands
    end

    attr_reader :name, :aberrations

    def initialize(*args)
      config_logging()
      chr = args[0]
      chr = chr.to_s  if chr.is_a?Fixnum

      raise ArgumentError, "#{chr} is not a valid chromosome identifier." unless (chr.is_a? String and chr.match(/^\d+|X|Y$/))
      @name = chr
      @aberrations = []
      #@normal_bands = bands(@name, File.open("HsBands.txt", 'r')) if (args.length > 1 and args[1].eql? true) ## TODO quit hardcoding
    end

    def to_s
      "#{@name}"
    end

    def aberration(obj)
      raise ArgumentError, "Not an Aberration object" unless obj.is_a? Aberration

      #obj.breakpoints.each do |bp|
      #  log.warn("Band #{bp.to_s} doesn't exist. Removing.") if @normal_bands.index(bp.to_s).nil?
      #end

      ## TODO Deal with bands, HOWEVER because the chromosome has aberration objects breakpoints can include
      ## bands for which no chromosome object is created

      #obj.breakpoints.reject {|bp|
      #  @normal_bands.index(bp.to_s).nil?
      #}

      @aberrations << obj
    end

    def breakpoints
      bps = []
      @aberrations.each { |a| bps << a.breakpoints }
      return bps
    end

    def fragments
      frags = []
      @aberrations.each do |a|
        frags << a.fragments
      end
      frags
    end

    :private
    def config_logging
      @log = Cytogenetics.logger
      #@log.progname = self.class.name
    end

  end

end