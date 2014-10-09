class AddBranchIdToBranches < ActiveRecord::Migration
  def change
    add_reference :branches, :branch, index: true
  end
end
