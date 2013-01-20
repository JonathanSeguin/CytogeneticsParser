module Cytogenetics

  module ChromosomeType
    Linear = "linear"
    Ring = "ring"
    DoubleMinute = "dmin"
    UndefinedFragment = "frag"
  end

  class Chromosome
    attr_reader :name, :aberrations, :type

    def initialize(chr, type = ChromosomeType::Linear)
      config_logging()
      chr = chr.to_s if chr.is_a? Fixnum
      raise ArgumentError, "#{chr} is not a valid chromosome identifier." unless (chr.is_a? String and chr.match(/^\d+|X|Y$/))

      @type = type
      @name = chr
      @aberrations = []
    end

    def is(type)
      return type.eql? @type
    end

    def to_s
      "#{@name}"
    end

    def aberration(obj)
      raise ArgumentError, "Not an Aberration object" unless obj.is_a? Aberration
      @aberrations << obj
    end

    def breakpoints
      return @aberrations.map { |a| a.breakpoints }

    end

    def fragments
      return @aberrations.map { |a| a.fragments }
    end

    :private

    def config_logging
      @log = Cytogenetics.logger
    end

  end

end