# frozen_string_literal: true

require 'capybara'
require 'capybara/dsl'
require 'selenium/webdriver'
# require 'capybara-webkit'

class LinkTest
  attr_accessor :dri_url, :metadata_fields, :default_image

  include Capybara::DSL

  def initialize
    Capybara.default_driver = :selenium_chrome_headless
    # # webkit supports status code
    # Capybara.default_driver = :webkit
  end

  def with_links(&_block)
    links = find_all('a.path span')
    if links.count.zero?
      puts("no links on #{title}")
      return
    end

    links.each do |link|
      yield(link)
    end
  end

  def check_links
    with_links do |link|
      link.click
      link_text = link.text
      # link always opens in new tab, so switch to it
      browser = page.driver.browser
      browser.switch_to.window(browser.window_handles.last)
      # selenium chrome doesn't support status_code, workaround
      puts("\t#{link_text}, #{title}") if title.match?(/not found/i)
      # close new tab
      browser.close
      browser.switch_to.window(browser.window_handles.first)
    end
  end

  def main
    # 0-introduction has no links to source
    %w[
      1-getting-started 2-queries 3-mutations 4-authentication
      5-connecting-nodes 6-error-handling 7-filtering 8-pagination 9-summary
    ].each do |page_name|
      puts(page_name)
      visit("https://www.howtographql.com/graphql-ruby/#{page_name}")
      check_links
    end
  end
end

LinkTest.new.main
