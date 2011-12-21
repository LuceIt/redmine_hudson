# $Id: hudson_test.rb 471 2010-03-22 02:05:01Z toshiyuki.ando1971 $
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../../../../app/models/setting'
require 'uri'
require 'net/http'
require 'mocha'

class HudsonTest < ActiveSupport::TestCase
  fixtures :projects, :repositories, :hudson_settings, :hudson_settings_health_reports, :hudson_jobs, :hudson_builds
  set_fixture_class :hudson_settings => HudsonSettings

  def test_project_should_be_eCookbook
    
    data_settings = hudson_settings(:one)
    hudson = Hudson.find(data_settings.project_id)

    data_project = projects(:projects_001)

    assert_equal data_project.name, hudson.project.name
    
  end

  def test_get_job_should_hudson_no_job
    
    data_settings = hudson_settings(:one)
    hudson = Hudson.find(data_settings.project_id)
    
    job = hudson.get_job(nil)
    
    assert job.is_a?(HudsonNoJob)
    
  end

  def test_hudson_api_errors_should_be_empty

    data_settings = hudson_settings(:one)
    hudson = Hudson.find(data_settings.project_id)

    assert_equal true, hudson.hudson_api_errors.empty?

  end

  def test_hudson_api_errors_should_has_hudson_error

    data_settings = hudson_settings(:one)
    hudson = Hudson.find(data_settings.project_id)

    hudson.fetch

    assert_equal 1, hudson.hudson_api_errors.length
    error = hudson.hudson_api_errors[0]
    assert error.is_a?(HudsonApiError)
    assert_equal "Hudson", error.class_name
    assert_equal "fetch", error.method_name
    assert error.exception.is_a?(HudsonApiException)

  end

  def test_hudson_api_errors_should_has_job_error

    @response_jobs = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
    @response_jobs.stubs(:content_type).returns("text/html")
    @response_jobs.stubs(:body).returns(get_response(:hudson_1_fetch_job))

    Net::HTTP.any_instance.stubs(:request).returns(@response_jobs).then.raises(SocketError)

    data_settings = hudson_settings(:one)
    hudson = Hudson.find(data_settings.project_id)

    hudson.fetch

    assert_equal 1, hudson.hudson_api_errors.length
    error = hudson.hudson_api_errors[0]
    assert error.is_a?(HudsonApiError)
    assert_equal "HudsonJob", error.class_name
    assert_equal "fetch_builds 'simple-ruby-application'", error.method_name
    assert error.exception.is_a?(HudsonApiException)

  end

  def test_hudson_api_errors_should_has_error

    @response_jobs = Net::HTTPServiceUnavailable.new(Net::HTTP.version_1_2, "503", "NG")
    @response_jobs.stubs(:content_type).returns("text/html")
    @response_jobs.stubs(:body).returns("503 error")

    Net::HTTP.any_instance.stubs(:request).returns(@response_jobs)

    data_settings = hudson_settings(:one)
    hudson = Hudson.find(data_settings.project_id)

    hudson.fetch

    assert_equal 1, hudson.hudson_api_errors.length
    error = hudson.hudson_api_errors[0]
    assert error.is_a?(HudsonApiError)
    assert_equal "Hudson", error.class_name
    assert_equal "fetch", error.method_name
    assert error.exception.is_a?(HudsonApiException)

  end

  def test_fetch_hudson_1

    @response_jobs = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
    @response_jobs.stubs(:content_type).returns("text/html")
    @response_jobs.stubs(:body).returns(get_response(:hudson_1_fetch_job))

    @response_job_build_detail = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
    @response_job_build_detail.stubs(:content_type).returns("text/html")
    @response_job_build_detail.stubs(:body).returns(get_response(:hudson_1_fetch_job_simple_ruby_application_build_detail))

    Net::HTTP.any_instance.stubs(:request).returns(@response_jobs, @response_job_build_detail)

    data_settings = hudson_settings(:one)

    hudson = Hudson.find(data_settings.project_id)
    data_job = hudson_jobs(:simple_ruby_application)
    job = hudson.get_job(data_job.name)
    build = job.get_build("1")
    assert_equal "", build.result
    assert_equal true, build.building?

    hudson.fetch

    hudson = Hudson.find(data_settings.project_id)
    assert hudson != nil

    data_job = hudson_jobs(:simple_ruby_application)
    job = hudson.get_job(data_job.name)
    assert_equal data_job.name, job.name
    assert_equal "red", job.state
    assert_equal "Ruby Small Application", job.description
    assert_equal "3", job.latest_build_number

    assert_equal 2, job.health_reports.length
    healthreport = job.health_reports[0]
    assert_equal "安定したビルド: 最近の5個中、2個ビルドに失敗しました。", healthreport.description
    assert_equal 59, healthreport.score

    healthreport = job.health_reports[1]
    assert_equal "Rcov coverage: Code coverage 70.0%(70.0)", healthreport.description
    assert_equal 87, healthreport.score

    build = job.get_build("1")
    assert_equal "FAILURE", build.result
    assert_equal false, build.building?
    
    changesets = build.changesets
    assert_equal 2, changesets.length
    assert_equal "16", changesets[0].revision
    assert_equal "15", changesets[1].revision

    testresult = build.test_result

    assert_equal 0, testresult.fail_count
    assert_equal 0, testresult.skip_count
    assert_equal 3, testresult.total_count

    artifacts = build.artifacts
    assert_equal 2, artifacts.length

    artifact = artifacts[0]
    assert_equal "app", artifact.display_path
    assert_equal "app.rb", artifact.file_name
    assert_equal "SimpleRubyApplication/source/app.rb", artifact.relative_path

    artifact = artifacts[1]
    assert_equal "readme", artifact.display_path
    assert_equal "readme.rdoc", artifact.file_name
    assert_equal "SimpleRubyApplication/readme.rdoc", artifact.relative_path


    build = job.get_build("2")
    assert_equal "SUCCESS", build.result
    assert_equal false, build.building?

    changesets = build.changesets
    assert_equal 1, changesets.length
    assert_equal "17", changesets[0].revision

    testresult = build.test_result

    assert testresult == nil

    artifacts = build.artifacts
    assert_equal 0, artifacts.length

    build = job.get_build("3")
    assert_equal "", build.result
    assert_equal true, build.building?

  end

  def test_add_job

    @response_jobs = Net::HTTPSuccess.new(Net::HTTP.version_1_2, '200', 'OK')
    @response_jobs.stubs(:content_type).returns("text/html")
    @response_jobs.stubs(:body).returns(get_response(:hudson_5_fetch_job))

    Net::HTTP.any_instance.stubs(:request).returns(@response_jobs)

    data_settings = hudson_settings(:five) # has no hudson-jobs records

    hudson = Hudson.find(data_settings.project_id)

    hudson.fetch

    assert_equal 2, hudson.jobs.length

    myjob = hudson.jobs.detect {|job| job.name == "One Job" }
    assert myjob != nil

    myjob = hudson.jobs.detect {|job| job.name == "Two Job" }
    assert myjob != nil

  end

  def test_hudson_find_by_project_id

    data_settings = hudson_settings(:five)

    target = Hudson.find_by_project_id(data_settings.project_id)

    assert_equal data_settings.project_id, target.settings.project_id
    assert_equal data_settings.url, target.settings.url

  end

  def test_hudson_auto_fetch_should_return_false

    Setting.plugin_redmine_hudson['autofetch'] = nil
    assert_equal false, Hudson.autofetch?

    Setting.plugin_redmine_hudson['autofetch'] = ""
    assert_equal false, Hudson.autofetch?

  end

  def test_hudson_auto_fetch_should_return_true
    Setting.plugin_redmine_hudson['autofetch'] = "t"
    assert_equal true, Hudson.autofetch?
  end

  def test_hudson_job_description_format_should_return_hudson
    Setting.plugin_redmine_hudson['job_description_format'] = nil
    assert_equal "hudson", Hudson.job_description_format

    Setting.plugin_redmine_hudson['job_description_format'] = ""
    assert_equal "hudson", Hudson.job_description_format

    Setting.plugin_redmine_hudson['job_description_format'] = "hudson"
    assert_equal "hudson", Hudson.job_description_format
  end

  def test_hudson_job_description_format_should_return_any
    Setting.plugin_redmine_hudson['job_description_format'] = "textile"
    assert_equal "textile", Hudson.job_description_format
  end

  def test_hudson_query_limit_builds_each_job_should_return_default
    Setting.plugin_redmine_hudson['query_limit_builds_each_job'] = nil
    assert_equal 100, Hudson.query_limit_builds_each_job

    Setting.plugin_redmine_hudson['query_limit_builds_each_job'] = ""
    assert_equal 100, Hudson.query_limit_builds_each_job

    Setting.plugin_redmine_hudson['query_limit_builds_each_job'] = "a123"
    assert_equal 100, Hudson.query_limit_builds_each_job

    Setting.plugin_redmine_hudson['query_limit_builds_each_job'] = "-100"
    assert_equal 100, Hudson.query_limit_builds_each_job

  end

  def test_hudson_query_limit_builds_each_job_should_return_number
    Setting.plugin_redmine_hudson['query_limit_builds_each_job'] = "150"
    assert_equal 150, Hudson.query_limit_builds_each_job
  end

  def test_hudson_query_limit_changesets_each_job_should_return_default
    Setting.plugin_redmine_hudson['query_limit_changesets_each_job'] = nil
    assert_equal 100, Hudson.query_limit_changesets_each_job

    Setting.plugin_redmine_hudson['query_limit_changesets_each_job'] = ""
    assert_equal 100, Hudson.query_limit_changesets_each_job

    Setting.plugin_redmine_hudson['query_limit_changesets_each_job'] = "a123"
    assert_equal 100, Hudson.query_limit_changesets_each_job

    Setting.plugin_redmine_hudson['query_limit_changesets_each_job'] = "-100"
    assert_equal 100, Hudson.query_limit_changesets_each_job

  end

  def test_hudson_query_limit_changesets_each_job_should_return_number
    Setting.plugin_redmine_hudson['query_limit_changesets_each_job'] = "150"
    assert_equal 150, Hudson.query_limit_changesets_each_job
  end

  def test_hudson_find_all
    items = Hudson.find(:all)

    assert_equal items.length, 5
    
    data_settings = hudson_settings(:one)
    detect_one = items.detect {|item| item.settings.url == data_settings.url}
    assert_equal data_settings.id, detect_one.settings.id

    data_settings = hudson_settings(:two)
    detect_one = items.detect {|item| item.settings.url == data_settings.url}
    assert_equal data_settings.id, detect_one.settings.id

    data_settings = hudson_settings(:three)
    detect_one = items.detect {|item| item.settings.url == data_settings.url}
    assert_equal data_settings.id, detect_one.settings.id

    data_settings = hudson_settings(:four)
    detect_one = items.detect {|item| item.settings.url == data_settings.url}
    assert_equal data_settings.id, detect_one.settings.id

    data_settings = hudson_settings(:five)
    detect_one = items.detect {|item| item.settings.url == data_settings.url}
    assert_equal data_settings.id, detect_one.settings.id
  end

end
