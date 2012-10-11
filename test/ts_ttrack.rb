# -*- coding: utf-8 -*-
require 'test/unit'
require 'TTrack'

class TestTimeTracker < Test::Unit::TestCase

  def test_init
    tt = TTrack.new 'testdb'
    assert_equal tt.class, TTrack
  end

  def test_start_stop
    tt = TTrack.new 'testdb'
    assert_equal true, tt.start('issuename_test', 'notes_test')
    assert_equal true, tt.stop
    assert_equal false, tt.stop
  end

end
