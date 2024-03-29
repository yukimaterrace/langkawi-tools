# frozen_string_literal: true

require 'faker'
require './lib/config'
require './lib/api'
require './lib/account_generator'
require './lib/pair_generator'
require './lib/talk_generator'

def main
  Config.load
  generate Config.job
end

def generate(job)
  case job['type']
  when 'account'
    generate_account(job['count'], job['password'], job['avators'])
  when 'pair'
    generate_pair(job['size_per_unit'], job['admin'])
  when 'talk'
    generate_talk(job['admin'], job['talk_count'])
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

def generate_talk(admin, talk_count)
  TalkGenerator.new.generate(admin, talk_count)
end

main
