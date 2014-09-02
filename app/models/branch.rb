class Branch < ActiveRecord::Base
  belongs_to :tree
  belongs_to :category
end
