require './lib/api'
require './lib/relation_generator'

class PairGenerator

  def initialize(admin_email, admin_password, size_per_unit)
    @api = API.new

    @admin_email = admin_email
    @admin_password = admin_password

    @size_per_unit = size_per_unit
  end

  def generate
    create_pairs_list
      .zip(relation_builders)
      .each do |pairs, builder|
        pairs.each do |owner, counter|
          builder::(owner, counter).execute
        end
      end
  end

  private
  
  def relation_builders
    [
      lambda { |o, c| RelationGenerator.new(o, c).build_for_pending },
      lambda { |o, c| RelationGenerator.new(c, o).build_for_pending },
      lambda { |o, c| RelationGenerator.new(o, c).build_for_withdraw },
      lambda { |o, c| RelationGenerator.new(c, o).build_for_withdraw },
      lambda { |o, c| RelationGenerator.new(o, c).build_for_accepted },
      lambda { |o, c| RelationGenerator.new(c, o).build_for_accepted },
      lambda { |o, c| RelationGenerator.new(o, c).build_for_declined },
      lambda { |o, c| RelationGenerator.new(c, o).build_for_declined },
      lambda { |o, c| RelationGenerator.new(o, c).build_for_disconnected },
      lambda { |o, c| RelationGenerator.new(c, o).build_for_disconnected },
      lambda { |o, c| RelationGenerator.new(o, c).build_for_refused },
      lambda { |o, c| RelationGenerator.new(c, o).build_for_refused }
    ]
  end

  def create_pairs_list
    login_admin
    accounts = list_account
    owner = accounts.first

    (0...relation_builders.count).map do |index|
      owners = (1..@size_per_unit).map { owner }
      counters = accounts.slice(1 + index * @size_per_unit, @size_per_unit)
      owners.zip counters
    end
  end

  def login_admin
    resp = @api.login({ email: @admin_email, password: @admin_password })
    @api.token = resp['token']    
  end

  def list_account
    resp = @api.list_account({ page: 0, page_size: relation_builders.count * @size_per_unit + 1 })
    resp['list']
  end
end
