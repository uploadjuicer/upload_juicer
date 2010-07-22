class CreateUploadTables < ActiveRecord::Migration
  def self.up
    create_table :upload_juicer_uploads do |t|
      t.string  :file_name
      t.string  :key
      t.integer :size
      t.integer :uploadable_id
      t.string  :uploadable_type

      t.timestamps
    end
    
    add_index :upload_juicer_uploads, :key
    add_index :upload_juicer_uploads, [:uploadable_id, :uploadable_type]
  end

  def self.down
    drop_table :upload_juicer_uploads
  end
end
