$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'wonder_navigation'
require 'simplecov'
SimpleCov.start do
  add_filter "spec"
end
