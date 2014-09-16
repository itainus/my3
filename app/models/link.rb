class Link < ActiveRecord::Base
  belongs_to :category
  has_many :leafs, :dependent => :destroy
  has_many :trees, :through => :leafs


  def self.create_if_not_exists(link_url, link_category_id)
    link = Link.where(:category_id => link_category_id).where(:url => link_url).first

    if link.present?
      Rails.logger.info "[DEBUG INFO] link '#{link_url}' (parent_id = #{link_category_id}) already exists"
    else
      Rails.logger.info "[DEBUG INFO] creating link '#{link_url}' (#{link_category_id})"
      link = Link.create(:url => link_url, :category_id => link_category_id)
    end

    return link
  end

  def self.suggest_categories(link_url)

    # Link.join
    # Rails.logger.info Link.where(:url => link_url).categories.as_json
    x = Category.joins(:links, :branches).where('links.url' => link_url).group('categories.id').order('count_categories_id desc').count('categories.id')
    # x = Link.where(:url => link_url).count(:category_id).maximum()
    # x = Link.select("category_id, count(category_id) as cid").group("category_id")

    # Rails.logger.info x.first.as_json

    return x
  end

end
