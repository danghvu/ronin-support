source 'https://rubygems.org'

gemspec

gem 'jruby-openssl',	'~> 0.7.0', :platforms => :jruby

group :development do
  gem 'rake',               '~> 10.0'
  gem 'rubygems-tasks',     '~> 0.1'
  gem 'rspec',              '~> 2.8'

  gem 'ripl',               '~> 0.3'
  gem 'ripl-multi_line',    '~> 0.2'
  gem 'ripl-auto_indent',   '~> 0.1'
  gem 'ripl-color_result',  '~> 0.3'
  gem 'rspec',              '~> 2.8'

  gem 'kramdown',           '~> 0.12'
end

group :test do
  case ENV['INFLECTOR']
  when 'activesupport'
    gem 'i18n',           '~> 0.4'
    gem 'tzinfo',         '~> 0.3.0'
    gem 'activesupport',  '~> 3.0.0'
  else
    gem 'dm-core',        '~> 1.0'
  end
end
