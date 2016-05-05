# require 'rails_helper'

RSpec.describe WonderNavigation::Menu do

  class MenuManager
    attr_accessor :menus
    def initialize
      @menus = {}
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

  let(:manager) {
    MenuManager.new
  }

  let(:menu_instance) {
    WonderNavigation::Menu.register(:menu_teste, manager) do
      path { "/" }
      label { "Start of Menu" }
      menu :nivel_a1, icon: "fa fa-user" do
        label { "Level A1" }
        path { "/a1" }
        menu :nivel_a2 do
          label {|obj| obj.label }
          menu :nivel_a3_1, "Level A3-1" do
            path { "/a1/a31"}
            menu :nivel_a4 do
              parent {|obj| obj.parent_object }
              label {|obj| obj.label }
              path {|obj| "/a1/a31/obj1/obj2" }
            end
          end
          menu :nivel_a3_2, "Level A3-2"
        end
      end
      menu :nivel_b1, "Level B1", path: "/b", icon: "fa fa-users" do
        menu :nivel_b2, label: "Level B2" do
          label {|objeto| objeto.to_s}
        end
      end
    end
  }

  let(:objeto) {
    OpenStruct.new({label: "Child Object", parent_object: OpenStruct.new({label: "Parent Object"})})
  }

  context "breadcrumbs" do
    it "should return in the exactly order with correct labels" do
      breadcrumbs = menu_instance.breadcrumb_for :nivel_a4, objeto
      expect(breadcrumbs.collect(&:label)).to eq(["Start of Menu", "Level A1", "Parent Object", "Level A3-1", "Child Object"])
      expect(breadcrumbs.collect(&:path)).to  eq(["/",             "/a1",       nil,             "/a1/a31",          "/a1/a31/obj1/obj2"])
    end

    it "should raise error when id is undefined" do
      expect{menu_instance.breadcrumb_for(:invalido)}.to raise_error(WonderNavigation::ENotDefinedMenu)
    end
  end

  context "menus" do
    context "should be returned according to the structure" do
      let(:visible_menus){
        menu_instance.menu_tree_flat(current_page: :nivel_a4).select(&:visible)
      }
      let(:paths) do
        visible_menus.collect(&:path)
      end
      it "paths" do
        expect(paths).to  eq(["/", "/a1", "/b"])
      end

      let(:labels) do
        visible_menus.collect(&:label)
      end
      it "labels" do
        expect(labels).to eq(["Start of Menu", "Level A1", "Level B1"])
      end

      let(:items) do
        visible_menus.collect(&:active)
      end
      it "active" do
        expect(items).to eq([true, true, false])
      end

    end
  end

end
