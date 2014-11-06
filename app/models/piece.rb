class Piece < ActiveRecord::Base
  # acts_as_taggable # Alias for acts_as_taggable_on :tags
  acts_as_taggable_on :folder, :keyword
  belongs_to :user
  has_many :logs
end
