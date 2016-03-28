# require 'rails_helper'

RSpec.describe WonderNavigation::MenuItem do

  class Manager
    attr_accessor :menus
    def initialize
      @menus = Hash.new
    end
    def set(id, instance)
      menus[id] = instance
    end
    # def get(id)
    #   fetch(id)
    # end
    def fetch(id)
      menus[id]
    end
  end

  let(:menu_id){
    :menu_test
  }

  let(:manager) {
    Manager.new
  }

  let(:menu_instance) {
    WonderNavigation::Menu.register(menu_id, manager) do
      label {"root"}
    end
  }

  context "should verify creation errors" do
    it "when label is not defined" do
      expect{WonderNavigation::MenuItem.new(menu_instance, 1, :teste)}.to raise_error(WonderNavigation::ELabelNotDefined)
    end
  end

  context "should update parent's children list when assigned parent_item=" do
    let(:parent){ WonderNavigation::MenuItem.new(menu_instance, 1, :parent, label: "Parent") }
    let(:child){ WonderNavigation::MenuItem.new(menu_instance, 1, :child, label: "Child") }

    it "with null value" do
      child.parent_item = parent
      child.parent_item = nil

      expect(parent.subitems).to_not include(child)
    end

    it "with not-null value" do
      child.parent_item = parent

      expect(parent.subitems).to include(child)
    end
  end

  context "resources" do
    let(:product) { OpenStruct.new({label: "Child Object"}) }

    let(:resource_manager) { Manager.new }

    let(:resource_menu_instance) {
      WonderNavigation::Menu.register(:menu_resource_test, resource_manager) { label {"root"} }
    }

    let!(:resource_menu) do
      WonderNavigation::Menu.register(:menu_resource_test, resource_manager) do |root|
        root.path do
          "/"
        end
        resource :products, label: "Products", path: "/products" do |_index, _new, show|
          show.label {|produto| produto.label}
          show.path {"/1"}
        end
      end
    end
    it "should register a resource correctly" do
      # require "byebug"; debugger
      breadcrumbs = resource_menu_instance.breadcrumb_for :products_show, product
      expect(breadcrumbs.collect(&:path)).to  eq(["/", "/products", "/1"])
    end
  end

  context "permissions" do
    let(:menu) do
      WonderNavigation::Menu.register(menu_id, manager) do
        label { "Root" }
        path { "/" }
        menu :products, label: "Products", path: "/products", permission: "products" do
          menu :product do
            path{|product| "/products/#{product.id}" }
            label{|product| product.label }
          end
        end
      end
    end

    let(:product) do
      OpenStruct.new(label: "Car", id: 1)
    end

    let(:user_with_permission)    { OpenStruct.new(id: 1, name: "Paul") }
    let(:user_without_permission) { OpenStruct.new(id: 2, name: "John") }

    it "should show when permitted" do
      uwp = user_with_permission
      WonderNavigation::Menu.register_permission_check(menu_id, manager) do |permission, current_user|
        current_user == uwp
      end
      menu_flat = menu.menu_tree_flat current_user: user_with_permission
      expect(menu_flat.collect(&:path)).to eq(["/", "/products"])
    end

    it "should hide when not permitted" do
      uwp = user_with_permission
      WonderNavigation::Menu.register_permission_check(menu_id, manager) do |permission, current_user|
        current_user == uwp
      end
      menu_flat = menu.menu_tree_flat current_user: user_without_permission
      expect(menu_flat.collect(&:path)).to eq(["/"])
    end

  end
end
