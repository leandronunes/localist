require File.dirname(__FILE__) + '/test_helper'


class LocalistTest < Test::Unit::TestCase

  def test_supportes_locales_return_value
    assert_kind_of Array, Localist.supported_locales
  end

  def test_set_new_supportes_locales
    locales= ['en-US','pt-BR']
    Localist.supported_locales= locales
    assert_equal locales, Localist.supported_locales
  end

  def test_set_a_invalid_locale_to_supportes_locales
    Localist.supported_locales = []
    locales= ['something-wrong']
    assert_raise(RuntimeError){Localist.supported_locales= locales}
    assert_equal [], Localist.supported_locales
  end

  def test_default_locale_is_the_one_choosen
    locales= ['en-US','pt-BR', 'es-ES']
    Localist.supported_locales= locales
    Localist.default_locale = 'pt-BR'
    assert_equal 'pt-BR', Localist.default_locale
  end

  def test_default_symbol_is_locale
    assert_equal :locale, Localist.symbol
  end

  def test_default_symbol_is_the_one_choosen
    assert_equal :locale, Localist.symbol
    another_symbol = :another
    Localist.symbol= another_symbol
    assert_equal another_symbol, Localist.symbol
  end

  def test_callback_is_the_one_choosen
    Localist.callback = nil
    assert_nil Localist.callback
    callback = lambda{|l| l == true}
    Localist.callback = callback
    assert_equal callback, Localist.callback
  end



end
