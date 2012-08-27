class Target::Notification::Campfire < Target
  register :campfire
  
  attribute :message, type: String
  attribute :source, type: String, default: 'mastermind'
  attribute :message_id, type: String
  attribute :message_type, type: String
  
end