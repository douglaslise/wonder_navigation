require "ostruct"
require "wonder_navigation/version"
require "wonder_navigation/menu"
require "wonder_navigation/menu_manager"
require "wonder_navigation/menu_item"
require "wonder_navigation/menu_entry"
require "wonder_navigation/deferrable_option"
require "wonder_navigation/crumb"
require "wonder_navigation/controller"

if defined?(ActionView)
  require "wonder_navigation/helper"
  ActionView::Base.send :include, WonderNavigation::Helper
end

module WonderNavigation
end
