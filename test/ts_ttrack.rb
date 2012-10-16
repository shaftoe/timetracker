# -*- coding: utf-8 -*-
require 'test/unit'
require 'TTrack'
require 'FileUtils'

class TestTimeTracker < Test::Unit::TestCase

  def setup
    FileUtils.rm('testdb')  # Remove testing db before any test
    @tt = TTrack.new('testdb')
  end

  def test_init
    assert_equal @tt.class, TTrack
  end

  def test_status
    assert @tt.commands.include? :status
    assert_nil @tt.status
  end

  def test_start_stop
    assert @tt.commands.include? :start
    assert @tt.start('issuename_test', 'notes_test')
    assert @tt.commands.include? :stop
    result = @tt.stop
    assert_equal result, {:name=>'issuename_test', :id=>1, :elapsed=>0}
    assert_equal false, @tt.stop
  end

  def test_start_start_stop
    assert @tt.start('issuename_test1')
    result = @tt.start('issuename_test2')
    assert_equal true, result[0]
    assert_equal result[1], {:name=>'issuename_test1', :id=>1, :elapsed=>0}
  end

  def test_status_when_nothing_running
    assert_nil @tt.status
  end

  def test_status_with_task_running
    assert @tt.start('issuename_test')
    status = @tt.status
    assert_equal 'issuename_test', status[:task]
    assert_kind_of Float, status[:elapsed]
    assert_not_equal 0, status[:elapsed]
  end

  def test_status_with_old_tasks
    assert @tt.start('issuename_test')
    assert @tt.start('issuename_test_2')
    assert @tt.start('issuename_test')
    assert @tt.start('issuename_test_2')
    status = @tt.status('issuename_test')
    assert_equal 0, status[:elapsed]
    assert_kind_of Float, status[:elapsed]
    assert_equal 'issuename_test', status[:task]
  end

  def test_status_wrong
    status = @tt.status('foo_issuename')
    assert_nil status
  end

  def test_report_void
    assert @tt.commands.include? :report
    assert_nil @tt.report
  end

  def test_report_with_name
    assert @tt.start('issuename_test')
    report = @tt.report('issuename_test')
    assert_kind_of Hash, report[0]
  end

  def test_report_with_fakename
    report = @tt.report('foo_issuename')
    assert_nil report
  end

  def test_duplicated_issuename
    assert @tt.start('issuename_test_clone')
    assert @tt.start('issuename_test_clone')
    report = @tt.report('issuename_test_clone')
    assert_kind_of Hash, report[1]
  end

  def test_cleanup_db
    assert @tt.commands.include? :init
    assert_equal [], @tt.init
    assert_nil @tt.report
  end

  def test_set_tstart
    timestamp_short = '2010-01-01 00:00'
    timestamp_full = '2010-01-01 00:00:00'
    assert @tt.start('issuename_test')
    assert @tt.set_tstart!(1, timestamp_short)
    assert_match timestamp_short, @tt.report('issuename_test')[0][:tstart]
    assert @tt.set_tstart!(1, timestamp_full)
    assert_equal timestamp_full, @tt.report('issuename_test')[0][:tstart]
  end

  def test_set_tstop
    timestamp_short = '2010-01-01 00:00'
    timestamp_full = '2010-01-01 00:00:00'
    assert @tt.start('issuename_test')
    assert @tt.set_tstop!(1, timestamp_short)
    assert_match timestamp_short, @tt.report('issuename_test')[0][:tstop]
    assert @tt.set_tstop!(1, timestamp_full)
    assert_equal timestamp_full, @tt.report('issuename_test')[0][:tstop]
  end

end
