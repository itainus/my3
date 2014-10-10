class AddDomainIdToLinkMetaData < ActiveRecord::Migration
  def change
    add_reference :link_meta_data, :domain, index: true
    # add_column :link_meta_data, :favicon, :text
  end
end
