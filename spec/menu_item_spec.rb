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
    def get(id)
      fetch(id)
    end
    def fetch(id)
      menus[id]
    end
  end

  let(:manager) {
    Manager.new
  }

  let(:menu_instance) {
    WonderNavigation::Menu.register(:menu_teste, manager) do
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

end
