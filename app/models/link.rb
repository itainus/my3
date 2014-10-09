class Link < ActiveRecord::Base
  belongs_to :category
  belongs_to :domain
  has_many :leafs, :dependent => :destroy
  has_many :branches, :through => :leafs
  has_one :link_meta_data, :inverse_of => :link


  def self.create_if_not_exists(link_url, link_category_id, link_meta_data)
    link = Link.where(:category_id => link_category_id).where(:url => link_url).first

    if link.present?
      Rails.logger.info "[DEBUG INFO] link '#{link_url}' (parent_id = #{link_category_id}) already exists"
    else
      Rails.logger.info "[DEBUG INFO] creating link '#{link_url}' (#{link_category_id})"
      link = Link.create(:url => link_url, :category_id => link_category_id)

      if link_meta_data.present?
        link.create_link_meta_data(link_meta_data)
      end

    end

    return link
  end

  def self.suggest_categories(link_url)

    # Link.join
    # Rails.logger.info Link.where(:url => link_url).categories.as_json
    # x = Category.joins(:links, :branches).where('links.url' => link_url).group('categories.id').order('count_categories_id desc').count('categories.id')

    return Link.joins(:leafs).where('links.url' => link_url).group('links.category_id').order('count_links_category_id desc').count('links.category_id')
    # x = Link.where(:url => link_url).count(:category_id).maximum()
    # x = Link.select("category_id, count(category_id) as cid").group("category_id")

    # Rails.logger.info x.first.as_json

  end

end
