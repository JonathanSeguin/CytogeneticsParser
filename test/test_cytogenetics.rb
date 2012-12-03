$LOAD_PATH.push File.expand_path("../lib", __FILE__)

require 'test/unit'
require 'cytogenetics'
require 'cytogenetics/karyotype'
require 'cytogenetics/breakpoint'
require 'cytogenetics/chromosome'
require 'cytogenetics/chromosome_aberrations'
require 'cytogenetics/aberration'
require 'cytogenetics/fragment'
require 'cytogenetics/karyotype_error'
require 'cytogenetics/version'

require 'cytogenetics/utils/karyotype_reader'
require 'cytogenetics/utils/band_reader'

class TestCytogenetics < Test::Unit::TestCase

  @@karyotype = "43-45,XY,add(2;3)(q13),-3,-5,dic(13;13)(q14;q32),der(6)t(2;6)(q12;p12)t(1;6)(p22;q21),der(5)t(5;17)(q13;q21),-7,i(8)(q10),-11,-17,ider(19)(q10)add(19)(q13)"


  def test_no_karyotype
    begin
      Cytogenetics.karyotype("foo")
    rescue => error
      assert_equal error.class, Cytogenetics::KaryotypeError
    end
  end

  def test_karyotype
    karyo = Cytogenetics.karyotype(@@karyotype)
    assert_equal karyo.class, Cytogenetics::Karyotype

    assert_equal karyo.report_ploidy_change.length, 5
    assert_equal karyo.report_breakpoints.length, 9
    assert_equal karyo.report_fragments.length, 5
    assert_equal karyo.ploidy, 2
    assert_equal karyo.sex, "XY"
  end

  def test_chromosome
    chr = Cytogenetics::Chromosome.new(6, true)
    assert_kind_of Cytogenetics::Chromosome, chr
    assert_equal chr.name, "6"


  end


  def test_invalid_breakpoints

  end

end