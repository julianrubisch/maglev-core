# frozen_string_literal: true

require 'jbuilder'

module Maglev
  class Engine < ::Rails::Engine
    isolate_namespace Maglev

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end    

    initializer 'maglev.theme_reloader' do |app|
      theme_path = Rails.root.join('app/theme')
      theme_reloader = app.config.file_watcher.new([], { theme_path.to_s => ['.yml'] }) do
        Maglev.local_themes = [Maglev::Theme.load(theme_path)]
      end
      app.reloaders << theme_reloader

      config.to_prepare do
        # everytime the code of the app or the engine changes, we reload the themes
        theme_reloader.execute
      end

      config.after_initialize do
        theme_reloader.execute
      end
    end

    initializer 'webpacker.proxy' do |app|
      insert_middleware = begin
        Maglev.webpacker.config.dev_server.present?
      rescue StandardError
        nil
      end
      next unless insert_middleware

      app.middleware.insert_before(
        0, Webpacker::DevServerProxy,
        ssl_verify_none: true,
        webpacker: Maglev.webpacker
      )
    end

    # Serves the engine's webpack when requested
    initializer 'webpacker.static' do |app|
      app.config.middleware.use(
        Rack::Static,
        urls: ['/maglev-packs'],
        root: File.expand_path(File.join(__dir__, '..', '..', 'public'))
      )
    end
  end
end
