# Use the app.rb file to load Ruby code, modify or extend the models, or
# do whatever else you fancy when the theme is loaded.

module Nesta
  class App
    # Uncomment the Rack::Static line below if your theme has assets
    # (i.e images or JavaScript).
    #
    # Put your assets in themes/default/public/default.
    #
    # use Rack::Static, :urls => ["/default"], :root => "themes/default/public"

    helpers do
      # Add new helpers here.
      def author_biography(name = nil)
        name ||= @page.metadata('author')
        if name
          template = name.downcase.gsub(/\W+/, '_').to_sym
          haml template, :layout => false
        end
      end
    end

    # Add new routes here.
  end
end

Haml::Helpers.send(:include, Gravatarify::Helper)
