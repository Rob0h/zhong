require_relative "helper"
require "zhong/web"
require "tilt/erubis"

class TestWeb < Minitest::Test
  include Rack::Test::Methods

  def app
    Zhong::Web
  end

  def test_index
    get "/"
    assert last_response.ok?
    assert_contains "<title>[TEST] Zhong</title>", last_response.body
    assert_contains Zhong::VERSION, last_response.body
  end

  def test_index_job
    Zhong.logger = test_logger

    Zhong.schedule do
      every(10.minutes, "test_web_job") { nil }
    end

    get "/"
    assert last_response.ok?
    assert_contains "test_web_job", last_response.body
    assert_contains "every 10 minutes", last_response.body
  end

  def test_disable_job
    Zhong.logger = test_logger

    Zhong.schedule do
      every(30.seconds, "test_disable_web_job") { nil }
    end

    job = Zhong.scheduler.find_by_name("test_disable_web_job")

    job.enable

    assert_equal false, job.disabled?

    post "/", "disable" => job.id
    assert last_response.ok?
    assert_contains "test_disable_web_job", last_response.body
    assert_contains "every 30 seconds", last_response.body
    assert_contains 'name="enable"', last_response.body
    assert_equal true, job.disabled?
  end

  def test_enable_job
    Zhong.logger = test_logger

    Zhong.schedule do
      every(12.hours, "test_enable_web_job") { nil }
    end

    job = Zhong.scheduler.find_by_name("test_enable_web_job")

    job.disable

    assert_equal true, job.disabled?

    post "/", "enable" => job.id
    assert last_response.ok?
    assert_contains "test_enable_web_job", last_response.body
    assert_contains "every 12 hours", last_response.body
    assert_contains 'name="disable"', last_response.body
    assert_equal false, job.disabled?
  end
end