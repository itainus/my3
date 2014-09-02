class Leaf < ActiveRecord::Base
  belongs_to :tree
  belongs_to :link
end
