class Category < ActiveRecord::Base
  belongs_to :category
  has_many :categories
  has_many :branches, :dependent => :destroy
  has_many :trees, :through => :branches
  has_many :links

  def self.create_if_not_exists(category_name, category_parent_id)
    category = Category.where(:category_id => category_parent_id).where(:name => category_name).first

    if category.present?
      Rails.logger.info "[DEBUG INFO] category '#{category_name}' (parent_id = #{category_parent_id}) already exists"
    else
      Rails.logger.info "[DEBUG INFO] creating category '#{category_name}' (#{category_parent_id})"
      category = Category.create(:name => category_name, :category_id => category_parent_id)
    end

    return category
  end

end
