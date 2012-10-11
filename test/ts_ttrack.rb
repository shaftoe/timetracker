# -*- coding: utf-8 -*-
require 'test/unit'
require 'TTrack'
require 'FileUtils'

class TestTimeTracker < Test::Unit::TestCase

  def test_init
    FileUtils.rm('testdb')  # Remove testing db before
    tt = TTrack.new 'testdb'
    assert_equal tt.class, TTrack
  end

  def test_status
    tt = TTrack.new 'testdb'
    assert_equal nil, tt.status
  end

  def test_start_stop
    tt = TTrack.new 'testdb'
    assert tt.start('issuename_test', 'notes_test')
    assert tt.stop
    assert_equal false, tt.stop
  end

  def test_status_with_data_when_nothing_running
    tt = TTrack.new 'testdb'
    status = tt.status('issuename_test')
    assert_equal 'issuename_test', status[:task]
    assert_equal 0, status[:elapsed]
    assert_equal Float, status[:elapsed_hours].class
  end

  def test_status_when_task_running
    tt = TTrack.new 'testdb'
    assert tt.start('issuename_test_status')

    status = tt.status
    assert_equal 'issuename_test_status', status[:task]
  end

  def test_status_with_old_tasks
    tt = TTrack.new 'testdb'
    status = tt.status('issuename_test')
    assert_equal 'issuename_test', status[:task]
    assert_equal 0, status[:elapsed]
    assert_equal Float, status[:elapsed_hours].class
  end

  def test_status_wrong
    tt = TTrack.new 'testdb'
    status = tt.status('foo_issuename')
    assert_equal nil, status
  end

end
