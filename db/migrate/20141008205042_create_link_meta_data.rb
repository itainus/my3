class CreateLinkMetaData < ActiveRecord::Migration
  def change
    create_table :link_meta_data do |t|
      t.references :link, index: true

      t.timestamps
    end
  end
end
