class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.references :tree, index: true
      t.references :category, index: true

      # t.timestamps
    end
  end
end
