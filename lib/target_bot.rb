require 'capybara/dsl'
require 'capybara-webkit'
require 'securerandom'

Capybara.current_driver = :webkit
Capybara.javascript_driver = Capybara.current_driver
Capybara::Webkit.configure do |config|
  config.allow_url("*")
end

class TargetBot
  include Capybara::DSL

  TARGET_URL = 'https://target.my.com'
  TARGET_SANDBOX_URL = 'https://target-sandbox.my.com'
  CREATE_APP_URL = '/create_pad_groups/'
  CREATE_PLACEMENT_TEMPLATE_URL = '/pad_groups/{id}/create/'
  APP_TEMPLATE_URL = '/pad_groups/{id}/'
  RETRY_COUNT = 2

  LOGIN_PAGE = {
      login_button: '.js-head-log-in.js-link.ph-button__inner.ph-button__inner_profilemenu.ph-button__inner_light.ph-button__inner_profilemenu_signin',
      sign_in_button: '.button.button_submit',
      logined_header: '.header-ts__profile__username.js-head-user-name'
  }
  CREATE_APP_PAGE = {
      description_field: '.pad-setting__description__input.js-setting-pad_description.js-setting-field',
      app_link_field: '.pad-setting__url__input.js-setting-pad-url',
      create_app_button: '.main-button__label'
  }
  PLACEMENT_TYPES = '.format-item'
  APPS_PAGE = {
      new_app_button: '.pad-groups-control-panel__button.pad-groups-control-panel__button_create',
      next_button_paginator: '.paginator__button.paginator__button_right.js-control-inc'
  }
  PLACEMENT_BUTTONS = {
      create_placement_button: '.create-pad-page__save-button.js-save-button',
      edit_app_button: '.pads-stat-page__pad-group-edit.js-pad-group-edit'
  }
  PLACEMENT_LINKS = '.pads-list__link.js-pads-list-label'

  attr_reader :success, :error_message, :result

  def initialize(login, pass, link, test = false)
    @login = login
    @pass = pass
    @link = link
    @test = test
    @result = {}
    @session = Capybara::Session.new(:webkit)
  end

  def run
    sign_in
    create_app
  end

  private

  def create_app
    @session.visit create_app_url
    key = SecureRandom.base64(5)
    description_field = wait { @session.find(CREATE_APP_PAGE[:description_field]) }
    description_field.set("#{description_field.value} #{key}")

    wait { @session.find(CREATE_APP_PAGE[:app_link_field]).set(@link) }

    button_create = wait { @session.find(CREATE_APP_PAGE[:create_app_button]) }
    another_placements_count = @session.all(PLACEMENT_TYPES).count - 1

    button_create.click

    wait { @session.find(APPS_PAGE[:new_app_button]) }

    begin
      link_to_app = @session.find("a", text: key)
    rescue Capybara::ElementNotFound
      next_button_paginator = wait { @session.find(APPS_PAGE[:next_button_paginator]) }
      raise 'Created app not found.' if next_button_paginator[:class].include?('_disabled')
      next_button_paginator.click
      retry
    end
    app_id = id_url(link_to_app[:href])
    create_placements(app_id, another_placements_count)
    prepare_result(app_id)
  end

  def create_placements(app_id, count)
    (1..count).each do |index|
      create_placement(app_id, index)
    end
  end

  def create_placement(app_id, index)
    loop do
      visit_by_template_url(app_id, CREATE_PLACEMENT_TEMPLATE_URL)
      save_button = wait { @session.find(PLACEMENT_BUTTONS[:create_placement_button]) }
      @session.all(PLACEMENT_TYPES)[index].click
      save_button.click
      wait(:without_exception) { @session.find(PLACEMENT_BUTTONS[:edit_app_button]) }
      break if placement_created?(app_id, index + 1)
    end
  end

  def placement_created?(app_id, count)
    visit_by_template_url(app_id, APP_TEMPLATE_URL)
    wait { @session.find(APPS_PAGE[:next_button_paginator]) }
    @session.all(PLACEMENT_LINKS).count == count
  end

  def prepare_result(app_id)
    @result[:app_id] = app_id
    @result[:placement_ids] = []

    visit_by_template_url(app_id, APP_TEMPLATE_URL)
    wait { @session.find(APPS_PAGE[:next_button_paginator]) }
    @session.all(PLACEMENT_LINKS).each do |link|
      @result[:placement_ids] << id_url(link[:href])
    end
  end

  def sign_in
    @session.visit target_url
    wait { @session.find(LOGIN_PAGE[:login_button]).click }
    @session.find_field('login').set(@login)
    @session.find_field('password').set(@pass)
    wait { @session.find(LOGIN_PAGE[:sign_in_button]).click }
    raise 'Incorrect login/pass' if wait(:without_exception) { @session.find(LOGIN_PAGE[:logined_header]) }.nil?
  end

  def id_url(url)
    url.gsub(/\D/, '')
  end

  def visit_by_template_url(app_id, template_url)
    @session.visit "#{target_url}#{template_url}".gsub(/{id}/, app_id)
  end

  def target_url
    return TARGET_SANDBOX_URL if @test
    TARGET_URL
  end

  def create_app_url
    "#{target_url}#{CREATE_APP_URL}"
  end

  def wait(without_exception = false, &block)
    old_wait_time = Capybara.default_max_wait_time
    retry_count = RETRY_COUNT
    begin
       result = yield
    rescue Capybara::ElementNotFound => e
      Capybara.default_max_wait_time = 30
      retry_count -= 1
      retry if retry_count > 0
      raise e unless without_exception
      nil
    end
    Capybara.default_max_wait_time = old_wait_time
    result
  end
end
