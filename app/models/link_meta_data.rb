class LinkMetaData < ActiveRecord::Base
  belongs_to :link, :inverse_of => :link_meta_data
  belongs_to :domain
end
