class CreateLiveContentItemVersions < ActiveRecord::Migration
  def change
    create_table :live_content_item_versions do |t|
      t.string :content_id
      t.integer :version, null: false
      t.string :base_path
      t.string :locale
      t.string :title
      t.string :description
      t.string :format
      t.datetime :public_updated_at

      t.json :details, null: false

      t.references :user, foreign_key: { on_delete: :restrict }
    end

    add_index :live_content_item_versions, [:content_id, :version], unique: true

    add_column :live_content_items, :version, :integer

    execute "update live_content_items set version=1"

    change_column_null :live_content_items, :version, false
  end
end