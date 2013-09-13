# config.ru
require 'happy'
require 'happy/extras/action_controller'
require 'haml'
require 'sass'
require 'sass/css'

class Css2ap < Happy::Controller
  def route
    layout 'layout/application.html.haml'
    on('convert') do
      @css, @path_to_be_deleted = params[:css], params[:path_to_be_deleted]
      @beautify_css = params[:beautify_css]
      @path_to_be_deleted.gsub! /\//, "\/"
      if @beautify_css
        input = @css.gsub("{", " {\n  ")
        input = input.gsub(",", ", ")
        input = input.gsub(";", ";\n  ")
        input = input.gsub(/([^;])\}/, '\1;' + "\n}\n\n")
        @css = input.gsub(/  ([^:]+):/, "  " + '\1: ')
      end
      @converted = @css.gsub /(\s*)url\(\"?#{@path_to_be_deleted}(.*)\"\)/, '\1image-url(\'\2\')'
      begin
        @converted = Sass::CSS.new(@converted).render(:scss)
      rescue Sass::SyntaxError => e
        @error = e
      end
      render 'home.html.haml'
    end
    render 'home.html.haml'
  end
end

use Rack::Static, :urls => ["/css", "/images"], :root => "public"
run Css2ap

