# frozen_string_literal: true

class AddDeviseToPrincipals < ActiveRecord::Migration[7.0]
  def self.up
    change_table :principals, bulk: true do |t|
      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end