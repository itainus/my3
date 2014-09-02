class CreateTrees < ActiveRecord::Migration
  def change
    create_table :trees do |t|
      t.string :name
      t.references :user, index: true

      t.timestamps
    end
  end
end
