class AddFaviconUrlToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :favicon_url, :text
  end
end
