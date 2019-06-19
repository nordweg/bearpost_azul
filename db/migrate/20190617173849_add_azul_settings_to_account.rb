class AddAzulSettingsToAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :azul_settings, :jsonb, default: {}
  end
end
