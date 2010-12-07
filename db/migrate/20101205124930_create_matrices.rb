class CreateMatrices < ActiveRecord::Migration
  def self.up
    create_table :matrices do |t|
      t.integer :size

      t.timestamps
    end
  end

  def self.down
    drop_table :matrices
  end
end
