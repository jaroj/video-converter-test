class AddStatusToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :status, :integer, default: 0
  end
end
