class Branch < ActiveRecord::Base
  belongs_to :tree
  belongs_to :category

  has_many :leafs, :dependent => :destroy
  has_many :links, :through => :leafs

  belongs_to :branch
  has_many :branches, :dependent => :destroy

  attr_accessor :ranking

  # def after_initialize
  # def after_find
  #   self.ranking = 1717
  # end

  def rank
    self.ranking
  end

  def as_json (options = nil)
    self.ranking = 171
    super(
      only: [:id],
      include: {
        category: {
            only: [:id, :name, :category_id]
        },
        branches: {
            only: [:id, :name]
        }
      },
      methods: [:leafs]
    )
  end

end
