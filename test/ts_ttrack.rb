# -*- coding: utf-8 -*-
require 'test/unit'
require 'TTrack'
require 'FileUtils'

class TestTimeTracker < Test::Unit::TestCase

  def test000_init
    FileUtils.rm('testdb')  # Remove testing db before
    tt = TTrack.new 'testdb'
    assert_equal tt.class, TTrack
  end

  def test001_status
    tt = TTrack.new 'testdb'
    assert_equal nil, tt.status
  end

  def test002_start_stop
    tt = TTrack.new 'testdb'
    assert tt.start('issuename_test', 'notes_test')
    assert tt.stop
    assert_equal false, tt.stop
  end

  def test003_status_with_data_when_nothing_running
    tt = TTrack.new 'testdb'
    status = tt.status('issuename_test')
    assert_equal 'issuename_test', status[:task]
    assert_equal 0, status[:elapsed]
    assert_equal Float, status[:elapsed_hours].class
  end

  def test004_status_when_task_running
    tt = TTrack.new 'testdb'
    assert tt.start('issuename_test_status')

    status = tt.status
    assert_equal 'issuename_test_status', status[:task]
  end

  def test005_status_with_old_tasks
    tt = TTrack.new 'testdb'
    status = tt.status('issuename_test')
    assert_equal 'issuename_test', status[:task]
    assert_equal 0, status[:elapsed]
    assert_equal Float, status[:elapsed_hours].class
  end

  def test006_status_wrong
    tt = TTrack.new 'testdb'
    status = tt.status('foo_issuename')
    assert_equal nil, status
  end

  def test007_report
    tt = TTrack.new 'testdb'
    report = tt.report
    assert_equal Hash, report[0].class
  end

  def test008_report_with_name
    tt = TTrack.new 'testdb'
    report = tt.report('issuename_test')
    assert_equal Hash, report[0].class
  end

  def test009_report_with_fakename
    tt = TTrack.new 'testdb'
    report = tt.report('foo_issuename')
    assert_equal nil, report
  end

  def test010_duplicated_issuename
    tt = TTrack.new 'testdb'
    assert tt.start('issuename_test')
    report = tt.report('issuename_test')
    assert_equal Hash, report[1].class
  end

end
