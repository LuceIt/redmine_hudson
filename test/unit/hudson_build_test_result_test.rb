# $Id: hudson_build_test_result_test.rb 471 2010-03-22 02:05:01Z toshiyuki.ando1971 $

require File.dirname(__FILE__) + '/../test_helper'

class HudsonBuildTestResultTest < ActiveSupport::TestCase

  def test_description_for_activity

    target = HudsonBuildTestResult.new
    target.fail_count = 3
    target.skip_count = 2
    target.total_count = 5

    assert_equal "TestResults: 3Failed 2Skipped Total-5", target.description_for_activity

  end

end
