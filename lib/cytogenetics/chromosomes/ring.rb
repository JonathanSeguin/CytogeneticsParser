require 'yaml'
require_relative '../chromosome'

module Cytogenetics

  class Ring < Chromosome

    attr_reader :length

    def initialize(*args)
      @name = args[0]
      @length = args[1] if args[1]
    end

  end

end