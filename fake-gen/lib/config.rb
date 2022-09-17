require 'faker'
require 'yaml'

class Config

  def self.load
    @@config = YAML.load_file('./resource/config.yaml')
    Faker::Config.locale = @@config['faker_locale']
  end

  def self.job
    @@config['job']
  end
end
