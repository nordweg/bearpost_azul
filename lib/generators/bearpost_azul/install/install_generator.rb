module BearpostAzul
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def create_initializer_file
        create_file "config/initializers/azul_initializer.rb", "Rails.application.config.carriers << Carrier::Azul"
      end

      def add_migrations
        run 'bundle exec rake bearpost_azul_engine:install:migrations'
      end

      def run_migrations
        run_migrations = ['', 'y', 'Y'].include?(ask 'Would you like to run the migrations now? [Y/n]')
        if run_migrations
          run 'bundle exec rails db:migrate'
        else
          puts 'Skipping rails db:migrate, don\'t forget to run it!'
        end
      end
    end
  end
end
