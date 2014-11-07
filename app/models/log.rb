class Log < ActiveRecord::Base
  belongs_to :piece
  belongs_to :user
  attr_accessor :created
  attr_accessor :created_display
end
