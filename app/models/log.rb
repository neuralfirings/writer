class Log < ActiveRecord::Base
  belongs_to :piece
  belongs_to :user
end
