# $Id: rexml_helper.rb 201 2009-07-04 15:56:53Z toshiyuki.ando1971 $
# To change this template, choose Tools | Templates
# and open the template in the editor.

module RexmlHelper
    
  def get_element_value(element, name)
    return "" if element == nil
    return "" if element.get_text(name) == nil
    return "" if element.get_text(name).value == nil
    return element.get_text(name).value
  end

end
