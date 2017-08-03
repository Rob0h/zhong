# Zhong [![Build Status](https://travis-ci.org/nickelser/zhong.svg?branch=master)](https://travis-ci.org/nickelser/zhong) [![Code Climate](https://codeclimate.com/github/nickelser/zhong/badges/gpa.svg)](https://codeclimate.com/github/nickelser/zhong) [![Test Coverage](https://codeclimate.com/github/nickelser/zhong/badges/coverage.svg)](https://codeclimate.com/github/nickelser/zhong) [![Gem Version](https://badge.fury.io/rb/zhong.svg)](http://badge.fury.io/rb/zhong)

Useful, reliable distributed cron. Tired of your cron-like scheduler running key jobs twice? Would you like to be able to run your cron server on multiple machines and have it "just work"? Have we got the gem for you.

Zhong uses Redis to acquire exclusive locks on jobs, as well as recording when they last ran. This means that you can rest easy at night, knowing that your customers are getting their monthly Goat Fancy magazine subscriptions and you are rolling around in your piles of money without a care in the world.

# Installation

Add this line to your application’s Gemfile:

```ruby
gem 'zhong'
```

## Usage

```ruby
Zhong.redis = Redis.new(url: ENV["ZHONG_REDIS_URL"])

Zhong.schedule do
  category "stuff" do
    every 5.seconds, "foo" do
      puts "foo"
    end

    every(1.minute, "running biz at 26th and 27th minute", at: ["**:26", "**:27"]) { puts "biz" }
    every(1.week, "running baz on mon and wed", at: ["mon 22:45", "wed 23:13"]) { puts "baz" }
    every(10.seconds, "boom every 10 seconds") { raise "fail" }
  end

  category "clutter" do
    every(1.second, "compute", if: -> (t) { t.wday == 3 && rand < 0.5 }) do
      puts "something happened on wednesday, maybe"
    end
  end

  # note: callbacks that explicitly false will cause event to not run
  on(:before_tick) do
    puts "ding"
    true
  end

  on(:after_tick) do
    puts "dong"
  end

  on(:before_run) do |job, time|
    puts "running #{job}"
    true # can conditionally run a specific job
  end

  on(:after_run) do |job, time, ran|
    puts "#{job} ran?: #{ran}"
  end

  error_handler do |e, job|
    puts "dang, #{job} messed up: #{e}"
  end
end
```

## History

View the [changelog](https://github.com/nickelser/zhong/blob/master/CHANGELOG.md).

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/nickelser/zhong/issues)
- Fix bugs and [submit pull requests](https://github.com/nickelser/zhong/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
