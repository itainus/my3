class Branch < ActiveRecord::Base
  belongs_to :tree
  belongs_to :category

  has_many :leafs, :dependent => :destroy
  has_many :links, :through => :leafs

  belongs_to :branch
  has_many :branches, :dependent => :destroy

  def as_json (options = nil)
    super(
        only: [:id],
        methods: [:leafs],
        include: {
            category: {
                only: [:id, :name, :category_id]
            },
            branches: {
                only: [:id, :name]
            }
        }
    )
  end

end
