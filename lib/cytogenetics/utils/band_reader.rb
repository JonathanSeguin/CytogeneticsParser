
module Cytogenetics

  class BandReader

    def initialize(file)
      read_file(file)
    end

    def read_file(file)
      file = File.open(file, 'r') unless file.is_a? File
      @bands_by_chr = {}
      file.each_line do |line|
        line.chomp!
        next if line.start_with?"#"
        line.match(/^(\d+|X|Y)([p|q].*)/)
        c = $1; b = $2
        (@bands_by_chr[c] ||= []) << "#{c}#{b}"
        @bands_by_chr[c] << "#{c}#{$1}" if b.match(/([p|q]\d+)\.\d+/)
      end
      @bands_by_chr.each_pair {|chr, bands| bands.uniq! }
    end

    def by_chr(chr = nil)
      return @bands_by_chr if chr.nil?
      return @bands_by_chr[chr]
    end

    def all
      return @bands_by_chr.values.flatten
    end

  end

end