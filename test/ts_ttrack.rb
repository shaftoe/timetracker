# -*- coding: utf-8 -*-
require 'test/unit'
require 'TTrack'

class TestTimeTracker < Test::Unit::TestCase

  def test_easy
    tt = TTrack.new '.testdb'
    assert_equal tt.class, TTrack
  end

end
