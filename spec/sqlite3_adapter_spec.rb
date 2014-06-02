require_relative 'spec_helper'

describe SQLite3Adapter do

  let(:test_db_name) { 'test.db' }
  let(:connection) { SQLite3::Database.new(test_db_name) }

  around(:each) do |example|
    connection.execute('CREATE TABLE IF NOT EXISTS key_value_store( key CHAR(100) PRIMARY KEY NOT NULL, value BLOB NOT NULL );')
    example.run
    connection.execute('DROP TABLE IF EXISTS key_value_store;')
  end

  context '[]' do
    it 'should pull the value for the key from the database' do
      sql = 'INSERT INTO key_value_store (key, value) VALUES (?, ?);'
      connection.execute(sql, 'test_key', 'test_value')
      expect(SQLite3Adapter.new(test_db_name)['test_key']).to eq('test_value')
    end
  end

  context '[]=' do
    it 'should create a row in db for key if it does not exist' do
      expect(connection.get_first_value('SELECT COUNT(*) FROM key_value_store WHERE key = ?', 'test_key')).to eq(0)

      expected_value = 'bah'
      SQLite3Adapter.new(test_db_name)['test_key'] = expected_value
      expect(connection.get_first_value('SELECT value FROM key_value_store WHERE key = ?', 'test_key')).to eq(expected_value)
    end

    it 'should update the value for the given key' do
      sql = 'INSERT INTO key_value_store (key, value) VALUES (?, ?);'
      connection.execute(sql, 'test_key', 'test_value')

      expect(connection.get_first_value('SELECT COUNT(*) FROM key_value_store WHERE key = ?', 'test_key')).to eq(1)

      expected_value = 'bah'
      SQLite3Adapter.new(test_db_name)['test_key'] = expected_value
      expect(connection.get_first_value('SELECT value FROM key_value_store WHERE key = ?', 'test_key')).to eq(expected_value)
    end
  end
end
