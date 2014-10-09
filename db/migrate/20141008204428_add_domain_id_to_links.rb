class AddDomainIdToLinks < ActiveRecord::Migration
  def change
    add_reference :links, :domain, index: true
  end
end
