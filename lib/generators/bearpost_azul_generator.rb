class BearpostAzulGenerator < Rails::Generators::Base
  def create_initializer_file
    create_file "config/initializers/correios_initializer.rb", "Rails.application.config.carriers << Carrier::Azul"
  end
end
