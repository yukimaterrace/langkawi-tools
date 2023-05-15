# frozen_string_literal: true

class Processor
  attr_accessor :state

  def initialize
    @state = {}
    @procs = []
  end

  def proc(&block)
    @procs.push(block)
    self
  end

  def execute
    @procs.each(&:call)
    self
  end

  def reset
    @state = {}
    self
  end
end
