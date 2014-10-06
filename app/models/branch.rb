class Branch < ActiveRecord::Base
  belongs_to :tree
  belongs_to :category

  has_many :leafs, :dependent => :destroy
  has_many :links, :through => :leafs

  belongs_to :branch
  has_many :branches
end
