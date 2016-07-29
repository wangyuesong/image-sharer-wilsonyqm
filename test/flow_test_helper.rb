require 'test_helper'

require 'active_support/test_case'
require 'capybara/rails'
require 'capybara/dsl'
require 'ae_page_objects'
require 'securerandom'

require 'socket'


Dir[File.dirname(__FILE__) + '/page_objects/document.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/page_objects/**/*.rb'].each { |file| require file}
Dir[File.dirname(__FILE__) + '/page_objects/*.rb'].each { |file| require file }

class FlowTestCase < ActiveSupport::TestCase
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  fixtures :all

  def log_in_as(user)
    PageObjects::LoginPage.visit.log_in!(
      email: user[:email],
      password: 'password'
    )
  end
end

# Tip 3 from http://blog.plataformatec.com.br/2011/12/three-tips-to-improve-the-performance-of-your-test-suite/
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end


def private_ipv4
  Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
end

def public_ipv4
  Socket.ip_address_list.detect{|intf| intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast? and !intf.ipv4_private?}.ip_address
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

# Capybara.default_driver = Capybara.javascript_driver
Capybara.register_driver :remote_browser do |app|
  # capabilities = {uuid: SecureRandom.hex}
  # ,
      # :desired_capabilities => Selenium::WebDriver::Remote::Capabilities.new(capabilities)
  Capybara::Selenium::Driver.new(app, :browser => :remote,
                                 :url => 'http://172.31.29.85:4444/wd/hub')
end
# ENV['HTTP_PROXY'] = ENV['http_proxy'] = nil
Capybara.current_driver = :remote_browser
if ENV['TEST_ENV_NUMBER'].nil?
  Capybara.server_port = 4000
else
  Capybara.server_port = "400#{ENV['TEST_ENV_NUMBER']}".to_i
end

Capybara.server_host = '0.0.0.0'
if ENV['TEST_ENV_NUMBER'].nil?
  Capybara.app_host = "http://#{private_ipv4}:4000"
else
  Capybara.app_host = "http://#{private_ipv4}:400#{ENV['TEST_ENV_NUMBER']}"
end


# Capybara.default_driver = Capybara.javascript_driver


module PageObjects
  class Site < AePageObjects::Site
  end
end

AePageObjects::Element.include(PageObjects::Extensions::ElementInlineErrorMessage)
AePageObjects::Node.include(PageObjects::Extensions::DynamicElementDeclaration)

PageObjects::Site.initialize!
