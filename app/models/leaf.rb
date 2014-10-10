class Leaf < ActiveRecord::Base
  belongs_to :branch
  belongs_to :link

  def as_json (options = nil)
    super(
      only: [:id, :name],
      include: {
          link: {
              only: [:id, :name, :url, :category_id],
              include: {
                  link_meta_data: {
                      only: [:domain_id]
                  }
              }
          }
      }
    )
  end
end
