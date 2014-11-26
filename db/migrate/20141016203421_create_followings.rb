class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.references :user, index: true
      t.references :branch, index: true

      t.timestamps
    end
  end
end
