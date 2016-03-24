module WonderNavigation
  class MenuManager
    class << self

      def fetch(menu_id)
        menus[menu_id]
      end

      def get(menu_id)
        load_menus
        fetch(menu_id)
      end

      def set(menu_id, menu_instance)
        menus[menu_id] = menu_instance
      end

      private

      def menus
        @menus ||= Hash.new
      end

      def reset
        @menus = nil
      end

      def load_menus
        if need_reload?
          reset
          load_register_files
          @loaded_file_mtimes = get_file_mtimes
        end
      end

      def load_register_files
        register_files.each do |file|
          Rails.logger.info("Reloading menu on file #{file}")
          instance_eval open(file).read, file
        end
      end

      def yml_files
        Dir[Rails.root.join("config", "navigation", "*.yml")]
      end

      def register_files
        yml_files.flat_map do |file|
          YAML.load(File.new(file)).flat_map do |folder, files|
            files.collect do |menu_file|
              File.join(Rails.root.join("config", "navigation", folder, "#{menu_file}.rb"))
            end
          end
        end
      end

      def need_reload?
        !@loaded_file_mtimes || files_modified?
      end

      def files_modified?
        Rails.env.development? && get_file_mtimes != @loaded_file_mtimes
      end

      def get_file_mtimes
        (yml_files + register_files).flatten.collect { |file| File.mtime(file) }
      end
    end
  end
end
