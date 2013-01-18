require 'test/unit'
require 'yaml'
require_relative '../lib/cytogenetics'

class TestCytogenetics < Test::Unit::TestCase

  @@karyotype = "43-45,XY,add(2;3)(q13),-3,-5,dic(13;13)(q14;q32),der(6)t(2;6)(q12;p12)t(1;6)(p22;q21),der(5)t(5;17)(q13;q21),-7,i(8)(q10),-11,-17,ider(19)(q10)add(19)(q13)"


  def test_no_karyotype
    begin
      Cytogenetics.karyotype("foo")
    rescue => error
      assert_equal error.class, Cytogenetics::KaryotypeError
    end
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