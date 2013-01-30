module Cytogenetics

  class BandReader

    # Opts:
    # :sep  = Column separator, default is \t if nothing is specified.
    # :chr = Chromosome column index
    # :band = Band column index
    # Note: If chr and band are in the same column as a single entry both should be the same index.
    # Other columns will be ignored.  If no opts are specified it is assumed that the bands are
    # in a single row as Chr[q|p]Band  (11q32.1)
    def initialize(file, opts = {})
      read_file(file, opts)
    end

    def read_file(file, opts)
      sep = opts[:sep] || "\t"
      chr_i, band_i = 0, 1
      if opts[:chr] and opts[:band]
        chr_i = opts[:chr]
        band_i = opts[:band]
      end

      file = File.open(file, 'r') unless file.is_a? File
      @bands_by_chr = {}
      file.each_line do |line|
        line.chomp!
        next if line.start_with? "#"
        cols = line.split(sep)
        if chr_i.eql? band_i
          cols[chr_i].match(/^(\d+|X|Y)([p|q].*)/)
          chr = $1; band = $2
        else
          chr = cols[chr_i]; band = cols[band_i]
        end
        (@bands_by_chr[chr] ||= []) << "#{chr}#{band}"
        if band.match(/([p|q]\d+)\.\d+/)
          @bands_by_chr[chr] << "#{chr}#{$1}"
        end
      end
      @bands_by_chr.each_pair { |chr, bands| bands.uniq! }
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