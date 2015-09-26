require 'sqlite3'

class SQLite3Adapter
  DEFAULT_FILE = ENV['TEST'] == 'true' ? 'test_jukebox.db' : 'jukebox.db'

  def initialize(db_file = DEFAULT_FILE)
    @db_file = db_file
  end

  def [](key)
    connection.get_first_value('SELECT value FROM key_value_store WHERE key = ?;', key)
  end

  def []=(key, value)
    sql = 'INSERT OR REPLACE
           INTO key_value_store (key, value)
           VALUES (:key, :value);'

    connection.execute(sql, key: key, value: value)
  end

  protected

  def connection
    @connection ||= SQLite3::Database.new(@db_file)
  end
end
