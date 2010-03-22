require 'test_helper'

class ProjectsHelperTest < ActionView::TestCase
  include ApplicationHelper
  
  test 'project type field generation' do
    tag = nil
    
    form_for Project.new do |f|
      tag = project_type_field f
    end

    assert_not_nil tag
    assert tag.include?('<select')
    assert tag.include?('</select>')
    assert tag.include?('id="project_project_type"')
  end
end