require 'faker'
require './lib/config'
require './lib/api'
require './lib/account_generator'

def main()
  unless ARGV.count == 1
    p 'usage: ruby main.rb [number of users to create]'
  end
  user_count = ARGV[0].to_i

  config()

  account_generator = AccountGenerator.new.build
  (1..user_count).each do
    account_generator.generate
  end
end

main()
