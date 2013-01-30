require 'test/unit'
require 'yaml'
require 'logger'
require_relative '../lib/cytogenetics'

class TestCytogenetics < Test::Unit::TestCase

  def setup
    log = Logger.new(STDOUT)
    log.level = Logger::ERROR
    Cytogenetics.logger = log
  end

  def test_no_karyotype
    begin
      Cytogenetics.karyotype("foo")
    rescue => error
      assert_equal error.class, Cytogenetics::KaryotypeError
    end
  end

  def test_bad_breakpoints
    k = Cytogenetics.karyotype("46, XX, t(12;14)(q14;q23q24),add(13)(q87)")
    assert_empty k.report_breakpoints
    assert_equal k.aberrations.length, 2
  end

  def test_sex
    k = Cytogenetics.karyotype("46, XX, t(12;14)(q14;q23)")
    assert_equal k.sex, 'XX'
    assert_equal k.normal_chr['X'], 2

    k = Cytogenetics.karyotype("46, XY, t(12;14)(q14;q23)")
    assert_equal k.sex, 'XY'
    assert_equal k.normal_chr['X'], 1
    assert_equal k.normal_chr['Y'], 1

    k = Cytogenetics.karyotype("46, XXY, t(12;14)(q14;q23)")
    assert_equal k.sex, 'XY'
    assert_equal k.normal_chr['X'], 1
    assert_equal k.normal_chr['Y'], 1
    assert_equal k.abnormal_chr['X'].length, 1

    k = Cytogenetics.karyotype("46, t(12;14)(q14;q23)")
    assert_equal k.sex, ''
  end

  def test_old_syntax
    kt = "46,XX,dic(1;21)(21qter->21p13::1p32->q11:)"
    k = Cytogenetics.karyotype(kt)
    assert_equal k.aberrations.keys, [:dic]
    assert_equal k.report_breakpoints, []
  end

  def test_karyotype
    kt = "43-45,XY,t(12;14)(q14;q23q24),add(2;3)(q13),-3,-5,dic(13;13)(q14;q32),der(6)t(2;6)(q12;p12)t(1;6)(p22;q21),der(5)t(5;17)(q13;q21),-7,i(8)(q10),-11,-17,ider(19)(q10)add(19)(q13)"
    k = Cytogenetics.karyotype(kt)
    assert_equal k.ploidy, 2
    assert_equal k.sex, "XY"
    assert_equal k.class, Cytogenetics::Karyotype
    assert_equal k.aberrations.keys.map{|a| a.to_s}.sort, ['trans', 'unk', 'loss', 'dic', 'der', 'iso'].sort
    assert_equal k.report_breakpoints.map{|b| b.to_s}.sort, ['13q14', '13q32', '2q12', '6p12', '1p22','6q21', '5q13', '17q21'].sort
    assert_equal k.report_fragments.map{|f| f.to_s}.sort, ['2qter --> 2q12', '6p12 --> 6q21', '1p22 --> 1pter', '5qter --> 5q13', '17q21 --> 17qter'].sort
    assert_equal k.report_ploidy_change.sort, ["-3", "-5", "-7", "-11", "-17"].sort
  end

  def test_chromosome
    chr = Cytogenetics::Chromosome.new(6, true)
    assert_kind_of Cytogenetics::Chromosome, chr
    assert_equal chr.name, "6"
  end

  def test_trans_no_der
    k = Cytogenetics.karyotype("46, XX, t(12;14)(q14;q23)")
    assert_equal k.ploidy, 2
    assert_equal k.sex, 'XX'
    assert_equal k.normal_chr['12'], 1
    assert_equal k.normal_chr['14'], 1
    assert_equal k.abnormal_chr.keys, ['12', '14']
    assert_equal k.abnormal_chr['12'].length, 1
    assert_equal k.abnormal_chr['14'].length, 1
  end

  def test_dic
    k = Cytogenetics.karyotype("46, XX, dic(12;14)(q14;q23)")
    assert_equal k.ploidy, 2
    assert_equal k.sex, 'XX'
    assert_equal k.normal_chr['12'], 2
    assert_equal k.normal_chr['14'], 2
    assert_equal k.abnormal_chr.keys, ['12']
    assert_equal k.abnormal_chr.has_key?('14'), false
  end

  def test_dmin  # not completely handling dmins, ring, or marker chromosomes
    k = Cytogenetics.karyotype("46, XX, dic(12;14)(q14;q23),1~9dmin(8)")
    assert_equal k.abnormal_chr.has_key?('8'), true
  end

end