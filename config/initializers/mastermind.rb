module Mastermind
  extend self
  
  def logger
    @logger ||= Rails.logger
  end
  
  def logger=(logger)
    @logger = logger
  end
  
  def dashboard
    url = ENV['REDIS_URL'] || ENV['REDISTOGO_URL'] || 'redis://localhost:6379/1'
    storage = Ruote::Redis::Storage.new(::Redis.connect(url: url, thread_safe: true))
    worker = Ruote::Worker.new(storage)
    @dashboard ||= Ruote::Dashboard.new(worker)
    @dashboard.configure('ruby_eval_allowed', true)
    @dashboard
  end
  
  def targets
    @targets ||= Hash.new.with_indifferent_access
  end
  
  def participants
    @participants ||= Hash.new.with_indifferent_access
  end
  
  def definitions
    # @definitions ||= Hash.new.with_indifferent_access
    @definitions ||= []
  end
  
  def define(attributes, &block)
    attributes = Hash[attributes].with_indifferent_access
    Mastermind.logger.debug "defined process #{attributes[:name]}", attributes
    pdef = Ruote.process_definition(attributes, &block)
    definition = Definition.new(pdef)
    definitions << definition unless definitions.map(&:name).include?(definition.name)
  end
  
end

Mastermind.dashboard.add_service('task_observer', Mastermind::TaskObserver)

Mastermind.dashboard.context.logger.noisy = true
# Mastermind.dashboard.context.engine.on_error = 'failure'
# Mastermind.dashboard.context.engine.on_terminate = 'success'

# require our models
Dir[Rails.root + "app/targets/**/*.rb"].each do |file|
  require file
end

# require our participants
Dir[Rails.root + "app/participants/**/*.rb"].each do |file|
  require file
end

# require our definitions
Dir[Rails.root + "app/definitions/**/*.rb"].each do |file|
  require file
end