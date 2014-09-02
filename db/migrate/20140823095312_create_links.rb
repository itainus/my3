class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :url
      t.references :category, index: true

      t.timestamps
    end
  end
end
