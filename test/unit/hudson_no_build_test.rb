# $Id: hudson_no_build_test.rb 471 2010-03-22 02:05:01Z toshiyuki.ando1971 $

class HudsonNoBuildTest < ActiveSupport::TestCase

  def test_building_should_return_false
    target = HudsonNoBuild.new
    assert_equal false, target.building?
  end
  
end
