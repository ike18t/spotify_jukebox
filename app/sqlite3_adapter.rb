require 'sqlite3'

class SQLite3Adapter
  DATABASE = 'jukebox.db'

  def [](key)
    sql = 'SELECT value
           FROM key_value_store
           WHERE key = ?;'
    connection.get_first_value(sql, key)
  end

  def []=(key, value)
    sql = 'INSERT OR REPLACE
           INTO key_value_store (key, value)
           VALUES (:key, :value);'

    connection.execute(sql, key: key, value: value)
  end

  protected

  def connection
    @connection ||= SQLite3::Database.new(DATABASE)
  end
end
