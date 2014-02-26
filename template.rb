# coding: utf-8
# rails _4.0.3_ new [app_name] -d mysql -T -m rails_template/template.rb

dir = File.dirname(__FILE__)

comment_lines 'Gemfile', "gem 'turbolinks'"

gem 'compass-rails', '~> 1.1.3'
gem 'active_decorator', '~> 0.3.4'
gem 'squeel', '~> 1.1.1'
gem 'yajl-ruby'
gem 'kaminari', '~> 0.15.1'
gem 'active_attr', '~> 0.8.2'
gem 'carrierwave', '~> 0.9.0'
gem 'carrierwave_backgrounder', '~> 0.3.0'
gem 'mini_magick', '~> 3.7.0'
gem 'simple_form', '~> 3.0.1'
gem 'paranoia', '2.0.1' #'~> 2.0' 2.0.2の不具合のためとりあえず
gem 'ransack', '~> 1.1.0'

use_bootstrap = if yes?('Use Bootstrap?')
                  uncomment_lines 'Gemfile', "gem 'therubyracer', platforms: :ruby"
                  gem 'bootstrap-sass', '~> 3.1.1'
                  true
                else
                  false
                end

use_sorcery = if yes?('Use sorcery?')
                gem 'sorcery', '~> 0.8.5'
                true
              else
                false
              end

use_unicorn = if yes?('Use unicorn?')
                uncomment_lines 'Gemfile', "gem 'unicorn'"
                true
              else
                false
              end

gem_group :development do
  gem 'thin'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'rack-mini-profiler'
end

gem_group :development, :test do
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'tapp'
  gem 'awesome_print'

  gem 'quiet_assets'
  gem 'timecop'
  gem 'colorize_unpermitted_parameters'
  gem 'xray-rails'

  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'guard-rspec', require: false
  gem 'spring-commands-rspec'
  gem 'factory_girl_rails'
  gem 'database_rewinder'
  gem 'faker'
end

run 'bundle install --path vendor/bundle'

generate 'kaminari:config'
generate 'rspec:install'
remove_dir 'test'

if use_bootstrap
  generate 'simple_form:install', '--bootstrap'
  # Simple form setting
  # ----------------------------------------------------------------
  comment_lines 'config/initializers/simple_form.rb', "config.button_class = 'btn btn-default'"
  comment_lines 'config/initializers/simple_form.rb', "config.form_class = 'form-horizontal'"
  comment_lines 'config/initializers/simple_form.rb', "config.error_notification_class = 'alert alert-danger'"
else
  generate 'simple_form:install'
end

# Application settings
# ----------------------------------------------------------------
application do
  %q{
    config.active_record.default_timezone = :local
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja

    config.generators do |g|
      g.orm :active_record
      g.test_framework :rspec, fixture: true, fixture_replacement: :factory_girl
    end

    config.autoload_paths += %W(#{config.root}/lib)
  }
end

comment_lines 'config/environments/development.rb', "HOSTNAME = 'localhost:3000'"
comment_lines 'config/environments/test.rb', "HOSTNAME = 'localhost:3000'"

# RSpec setting
# ----------------------------------------------------------------
remove_file 'spec'
directory File.expand_path('spec', dir), 'spec', recursive: true

# Sorcery setting
# ----------------------------------------------------------------
if use_sorcery
  sorcery_command = 'sorcery:install'
  sorcery_command += ' remember_me' if yes?('Use remember_me')
  sorcery_command += ' reset_password' if yes?('Use reset_password')
  sorcery_command += ' user_activation' if yes?('Use user_activation')
  sorcery_command += ' activity_logging'if yes?('Use activity_logging')
  generate sorcery_command
  route "get 'login' => 'sessions#new', as: :login"
  route "delete 'logout' => 'sessions#destroy', as: :logout"
end

# .gitignore settings
# ----------------------------------------------------------------
remove_file '.gitignore'
create_file '.gitignore' do
  body = <<EOS
# Ignore schema.rb
/db/schema.rb

# Ignore bundler config.
/.bundle

# Ignore the default SQLite database.
/db/*.sqlite3
/db/*.sqlite3-journal

# Ignore database.yml
/config/database.yml

# Ignore all logfiles and tempfiles.
/log/*.log
/tmp

# Ignore all bundle gems
/vendor/bundle/
/vendor/cache/

# Ignore Eclipse project
.project

# Ignore action cache
/public/*.json

# Ignore jasmine-headless-webkit cache
/.jhw-cache

# Ignore asset cache
/public/assets

# Ignore uploaded images
/public/uploads/

# Ignore .ruby-version
.ruby-version

# Ignore .DS_Store
.DS_Store

# Ignore swap file
*.swp

# Ignore .dropbox
.dropbox

# Ignore "Icon\r"
Icon^M^M
EOS
end

# Root path settings
# ----------------------------------------------------------------
generate 'controller', 'pages main'
route "root 'pages#main'"

# Create directories
# ----------------------------------------------------------------
empty_directory 'app/decorators'
create_file 'app/decorators/.gitkeep'

run "cp config/database.yml config/database.yml.sample"

[:development, :test].each do |env|
  run "RAILS_ENV=#{env} bundle exec rake db:drop"
  run "RAILS_ENV=#{env} bundle exec rake db:create"
end

if use_sorcery
  environment "config.action_mailer.default_url_options = { host: HOSTNAME }", env: 'development'
  environment "config.action_mailer.default_url_options = { host: HOSTNAME }", env: 'test'
end
exit
