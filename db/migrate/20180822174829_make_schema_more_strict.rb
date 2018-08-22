class MakeSchemaMoreStrict < ActiveRecord::Migration[5.2]
  def change
    change_column_null :contests, :name, false
    change_column_null :desk_assignment_histories, :desk_id, false
    change_column_null :desks, :floor_id, false
    change_column_null :desks, :name, false
    change_column_null :floors, :name, false
    change_column_null :machines, :mac, false
    change_column_null :passwords, :person_id, false
    change_column_null :passwords, :password_tier_id, false
    change_column_null :passwords, :plaintext_password, false
    change_column_null :teams, :slug, false
    change_column_null :teams, :name, false

    add_index :floors, :name, unique: true, name: 'index_floors_on_name2'
    remove_index :floors, name: 'index_floors_on_name'

    add_index :machines, :mac, unique: true, name: 'index_machines_on_mac2'
    remove_index :machines, name: 'index_machines_on_mac'

    add_index :password_tiers, :contest_id, unique: true, name: 'index_password_tiers_on_contest_id2'
    remove_index :password_tiers, name: 'index_password_tiers_on_contest_id'

    add_index :passwords, %i(person_id password_tier_id), unique: true, name: 'index_passwords_on_person_id_and_password_tier_id2'
    remove_index :passwords, name: 'index_passwords_on_person_id_and_password_tier_id'

    add_index :people, :login, unique: true, name: 'index_people_on_login2'
    remove_index :people, name: 'index_people_on_login'

    add_index :teams, :slug, unique: true, name: 'index_teams_on_slug2'
    remove_index :teams, name: 'index_teams_on_slug'

  end
end
