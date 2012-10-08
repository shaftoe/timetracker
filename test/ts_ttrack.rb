require 'test/unit'
require 'TTrack'

class TestTimeTracker < Test::Unit::TestCase

  def test_easy
    assert_nil TTrack.new.status('wordpress')
  end

end
