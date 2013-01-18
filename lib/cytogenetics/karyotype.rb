require 'yaml'
require_relative 'utils/karyotype_reader'

module Cytogenetics

  class Karyotype

    @@haploid = 23

    attr_reader :aberrations, :karyotype, :ploidy, :sex, :abnormal_chr, :normal_chr, :original_karyotype

    class<<self
      attr_accessor :aberration_objs, :unclear_aberrations, :log
    end

    def initialize(karyotype_str)
      config_logging()
      raise ArgumentError, "#{karyotype_str} is not a karyotype." unless (karyotype_str.is_a? String and karyotype_str.length > 1)
      @log.info("Reading karyotype #{karyotype_str}")

      @karyotype = karyotype_str.gsub(/\s/, "")
      @original_karyotype = @karyotype # just to keep it around before it gets cleaned up
      @normal_chr = {}; @abnormal_chr = {}; @aberrations = {}; @unclear_aberrations = [];
      setup_abberation_objs()
      prep_karyotype()
      handle_ploidy_diff()
      analyze()
    end

    def analyze
      Aberration.aberration_type.each do |abr_type|
        next unless @aberrations.has_key? abr_type
        regex = @aberration_obj[abr_type].regex

        @aberrations[abr_type].each do |abr|
          match = abr.match(regex)
          unless (match.captures.length >= @aberration_obj[abr_type].expected_chromosome)
            @log.warn("Aberration #{abr_type} expects #{@aberration_obj[abr_type].expected_chromosome} chromosomes but #{match.captures.length} found")
          end

          ## With a translocation but not a derivative you should get one chromosome for each translocated t(7;4) --> 7, 4 with breakpoints
          ## With all others (so far) it should result in one chromosome so just take the first one
          if abr_type.to_s.eql? ChromosomeAberrations::Translocation.type.to_s
            match.captures.each do |c|
              chr = Chromosome.new(c, true)
              chr.aberration(@aberration_obj[abr_type].new(abr))
              (@abnormal_chr[chr.name] ||= []) << chr
              # Example: when a translocation is indicated without a derivative it means that there's no new chromosome, but each chromosome
              # in the translocation is one of the normal pair.  t(9:22)(q43;q11)  Should have 1 normal 9 and 1 normal 22, then 1 abnormal of each
              @normal_chr[c] = 1 unless (@aberration_obj[abr_type].expected_chromosome.eql? 1 or c.eql? 'Y')
            end
          else
            chr = Chromosome.new(match.captures[ @aberration_obj[abr_type].chromosome_regex_position ])
            chr.aberration(@aberration_obj[abr_type].new(abr))
            (@abnormal_chr[chr.name] ||= []) << chr
          end
        end
      end
    end

    # get breakpoints for the karyotype
    def report_breakpoints
      bps = Array.new
      @abnormal_chr.each_pair do |c, chr_list|
        chr_list.each do |chr|
          bps << chr.breakpoints
        end
      end
      bps.delete_if { |c| c.empty? }
      bps.flatten!
      return bps
    end

    def report_fragments
      frags = []
      @abnormal_chr.each_pair do |c, chr_list|
        chr_list.each do |chr|
          frags << chr.fragments
        end
      end
      frags.delete_if { |c| c.empty? }
      frags.flatten!
      return frags
    end

    def report_ploidy_change
      pd = []
      pd << @aberrations[:loss].map { |e| "-#{e}" } if @aberrations[:loss]
      pd << @aberrations[:gain].map { |e| "+#{e}" } if @aberrations[:gain]
      pd.flatten!
      return pd
    end

    def summarize
      summary = "NORMAL CHROMOSOMES\n"
      @normal_chr.each_pair do |chr, count|
        summary = "#{summary} #{chr}: #{count}\n"
      end

      summary = "#{summary}\nABNORMAL:"
      @abnormal_chr.each_pair do |chr, list|
        summary = "#{summary}\n#{chr}"
        list.each do |c|
          summary = "#{summary}\n#{c.aberrations}\n"
          summary = "#{summary}\n#{c.breakpoints}\n"
        end
      end
    end

    # -------------------- # PRIVATE # -------------------- #
    :private

    def config_logging
      @log = Cytogenetics.logger
      #@log.progname = self.class.name
    end


    def setup_abberation_objs
      @aberration_obj = Aberration.aberration_objs
    end


    def handle_ploidy_diff
      @aberrations[:loss].each { |c| @normal_chr[c] -= 1 } if @aberrations[:loss]
      @aberrations[:gain].each { |c| @normal_chr[c] += 1 } if @aberrations[:gain]
    end

    # determine ploidy & gender, clean up each aberration and drop any "unknown"
    def prep_karyotype
      @karyotype.gsub!(/\s/, "")
      clones = @karyotype.scan(/(\[\w+\])/).collect { |a| a[0] }
      @log.warn("Karyotype is a collection of clones, analysis may be inaccurate.") if clones.length > 3

      @karyotype.gsub!(/\[\w+\]/, "") # don't care about numbers of cells: [5] or [cp10], there are some other problematic things in [] but they are just being ignored currently

      (pl, sc) = @karyotype.split(",")[0..1]
      if (pl and sc)
        @ploidy = KaryotypeReader.calculate_ploidy(pl, @@haploid)
        sex_chr = KaryotypeReader.determine_sex(sc)
      else
        raise KaryotypeError, "'#{@karyotype}' is not a valid karyotype. Ploidy and sex defnitions are absent"
      end

      ## Set up the normal chromosome array based on the ploidy value
      (Array(1..23)).each { |c| @normal_chr[c.to_s] = @ploidy.to_i }

      # sometimes the sex is not indicated and there's no case information to figure it out, so start reading karyotype from this position
      (sex_chr.values.inject { |sum, v| sum+v }.eql? 0) ? (karyotype_index = 1) : (karyotype_index = 2)

      sex_chr_count = sex_chr.values.inject { |sum, v| sum+v }
      (sex_chr_count.eql? 0) ? (karyotype_index = 1) : (karyotype_index = 2)

      case
        when ((sex_chr['X'] > 0 and sex_chr['Y'] > 0) or (sex_chr['X'].eql? 0 and sex_chr['Y'] > 0))
          @sex = 'XY'
        when (sex_chr['X'] > 0 and sex_chr['Y'].eql? 0)
          @sex = 'XX'
        else
          @sex = ""
      end


      ## I'm sure there's a cleaner way to do this but I'm stuck at the moment
      sex_chr.each_pair { |c, count| @normal_chr[c] = count }
      (1..sex_chr['Y']).each do |i|
        @normal_chr['Y'] = 1
        (@abnormal_chr['Y'] ||= []) << Chromosome.new('Y', ChromosomeAberrations::ChromosomeGain.new('Y')) if i > 1
      end

      (1..sex_chr['X']).each do |i|
        if @normal_chr['Y'] > 0
          @normal_chr['X'] = 1
          (@abnormal_chr['X'] ||= []) << Chromosome.new('X', ChromosomeAberrations::ChromosomeGain.new('X')) if i > 1
        else
          @normal_chr['X'] = 2
          (@abnormal_chr['X'] ||= []) << Chromosome.new('X', ChromosomeAberrations::ChromosomeGain.new('X')) if i > 2
        end
      end


      # deal with the most common karyotype string inconsistencies
      cleaned_karyotype = []

      @karyotype.split(",")[karyotype_index..-1].each do |abr|
        cleaned_karyotype |= [cleaned_karyotype, KaryotypeReader.cleanup(abr)].flatten
      end
      @karyotype = cleaned_karyotype

      # classify each type of aberration in the karyotype
      @karyotype.each do |k|
        abrclass = Aberration.classify_aberration(k)
        @aberrations[abrclass] = [] unless @aberrations.has_key? abrclass
        @aberrations[abrclass] << k.sub(/^(\+|-)?/, "")
      end

      @aberrations.each_pair do |abrclass, abrlist|
        next if (abrclass.eql? ChromosomeAberrations::ChromosomeGain.type or abrclass.eql? ChromosomeAberrations::ChromosomeLoss.type)
        # aberrations other than chromosome gains/losses should be uniquely represented

        counts = abrlist.inject(Hash.new(0)) { |h, i| h[i] += 1; h }
        counts.each_pair { |k, v| @log.warn("#{k} was seen multiple times. Analyzed only once.") if v > 1 }

        @aberrations[abrclass] = abrlist.uniq
      end

    end
  end
end