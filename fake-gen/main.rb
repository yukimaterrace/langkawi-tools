require 'faker'
require './lib/config'
require './lib/api'
require './lib/account_generator'
require './lib/pair_generator'

def main()
  Config.load
  job = Config.job

  case job['type']
  when 'account' then
    generate_account(job['count'], job['password'], job['avators'])
  when 'pair' then
    generate_pair(job['size_per_unit'], job['admin'])
  else
    p 'unrecognized job'
  end
end

def generate_account(count, password, avators)
  account_generator = AccountGenerator.new(password, avators).build
  (1..count).each do
    account_generator.generate
  end
end

def generate_pair(size_per_unit, admin)
  PairGenerator
    .new(admin['email'], admin['password'], size_per_unit)
    .generate
end

main()
