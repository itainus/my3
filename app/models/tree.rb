class Tree < ActiveRecord::Base
  belongs_to :user

  has_many :branches, :dependent => :destroy
  has_many :categories, :through => :branches

  has_many :leafs, :dependent => :destroy
  has_many :links, :through => :leafs

  def self.create_new(user_id, name)
    Rails.logger.info "[DEBUG INFO] ############## Tree - create_new - user_id = #{user_id}, name = #{name} ##############"
    tree = Tree.create(:user_id => user_id, :name => name)
    tree.branches.create(:tree_id => tree.id, :category_id => 1)
  end

  def branch_category(category_id)
    Rails.logger.info "[DEBUG INFO] ############## Tree - branch_category - category_id = #{category_id} ##############"

    category = Category.find(category_id)

    if category.present?
      while !self.branches.exists?(:category_id => category_id)
        Rails.logger.info "[DEBUG INFO] adding branch (category_id = #{category_id})"
        self.branches.create(:tree_id => self.id, :category_id => category_id)
        category_id = category.category_id
      end
    else
      Rails.logger.info "[DEBUG INFO] category '#{category_id}' dose not exists"
    end
  end

  def leaf_link(link, link_name)
    Rails.logger.info "[DEBUG INFO] ############## Tree - leaf_link - link_id = #{link.id}, link_name = '#{link_name}' ##############"

    if self.links.exists?(:id => link.id)
      Rails.logger.info "[DEBUG INFO] tree already has leaf with link_id = #{link.id}"
    else
      Rails.logger.info "[DEBUG INFO] adding leaf (link_id = #{link.id})"
      self.leafs.create(:tree_id => self.id, :link_id => link.id, :name => link_name)

      self.branch_category(link.category_id)
    end
  end

  private
  def category_params
    params.require(:category).permit(:name, :category_id)
  end
end
