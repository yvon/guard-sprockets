require 'guard/guard'
require 'sprockets'

module ::Guard
  class Sprockets < Guard
    IN_DIR  ||= Pathname.new 'app/assets/'
    OUT_DIR ||= Pathname.new 'public/'

    def initialize(watchers = [], options = {})
      @sprockets = ::Sprockets::Environment.new
      @sprockets.append_path('.')

      dependencies_watchers = []

      watchers.each do |watcher|
        Dir.glob(watcher.pattern).each do |file|
          asset  = compile_asset(file)
          action = lambda { file }
          asset.dependencies.each do |dependency|
            path =  dependency.pathname.relative_path_from(Pathname.pwd)
            dependencies_watchers << Watcher.new(path.to_s, action)
          end
        end
      end

      super(watchers + dependencies_watchers, options)
    end

    def compile_asset file
      asset         = @sprockets[file]
      relative_path = asset.pathname.relative_path_from(Pathname.pwd)
      basename      = relative_path.relative_path_from(IN_DIR)
      output_path   = OUT_DIR + basename

      puts "Compiling #{basename}"
      File.open(output_path, 'w') { |f| f.write asset }
      asset
    end

    def run_on_change files
      files.each { |f| compile_asset(f) }
    end
  end
end
