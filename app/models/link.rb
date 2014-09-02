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

end
