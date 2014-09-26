class CreateLeafs < ActiveRecord::Migration
  def change
    create_table :leafs do |t|
      t.string :name, :null => true
      t.references :branch, index: true
      t.references :link, index: true

      # t.timestamps
    end
  end
end
