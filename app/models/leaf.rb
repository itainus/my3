class Leaf < ActiveRecord::Base
  belongs_to :branch
  belongs_to :link
end
