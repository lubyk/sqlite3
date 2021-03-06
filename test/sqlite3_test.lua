--[[------------------------------------------------------

  sqlite3 test
  ------------

  SQLite3 database. The tests here are adapted from
  the LuaSQLite examples and tests.

--]]------------------------------------------------------
require 'lubyk'

local should = test.Suite('sqlite3')

local function mockDb(no_fill)
  local db = sqlite3.open_memory()

  db:exec 'CREATE TABLE test (id INTEGER PRIMARY KEY, content);'

  if not no_fill then
    db:exec[[
      INSERT INTO test VALUES (NULL, 'Hello World');
      INSERT INTO test VALUES (NULL, 'Hello Lua');
      INSERT INTO test VALUES (NULL, 'Hello SQLite3')
    ]]
  end

  return db
end

function should.open(t)
  local db = sqlite3.open_memory()
  assertType('userdata', db)
end

function should.prepareInsert(t)
  local db = sqlite3.open_memory()

  db:exec[[ CREATE TABLE test (id INTEGER PRIMARY KEY, content) ]]

  local stmt = db:prepare[[ INSERT INTO test VALUES (:key, :value) ]]

  stmt:bind_names{  key = 1,  value = "Hello World"    }
  stmt:step()
  assertEqual(1, db:last_insert_rowid())
  stmt:reset()
  stmt:bind_names{  key = 2,  value = "Hello Lua"      }
  stmt:step()
  assertEqual(2, db:last_insert_rowid())
  stmt:reset()
  stmt:bind_names{  key = 3,  value = "Hello SQLite3"  }
  stmt:step()
  assertEqual(3, db:last_insert_rowid())
  stmt:finalize()

  for row in db:nrows("SELECT * FROM test") do
    if row.id == 1 then
      assertEqual('Hello World', row.content)
    elseif row.id == 2 then
      assertEqual('Hello Lua', row.content)
    elseif row.id == 3 then
      assertEqual('Hello SQLite3', row.content)
    end
  end
end

function should.prepareSelect(t)
  local db = mockDb()
  local stmt = db:prepare[[ SELECT content FROM test WHERE id = :id ]]
  stmt:bind_names{id = 2}
  assertEqual('Hello Lua', stmt:first_row()[1])
  assertEqual('Hello Lua', stmt:first_row()[1])
end

function should.delete(t)
  local db = mockDb()
  db:exec 'DELETE from test;'
  local stmt = db:prepare[[ SELECT COUNT(*) FROM test ]]
  assertEqual(0, stmt:first_row()[1])
end

function should.backupRestore(t)
  local db = mockDb()
  local s = db:backup()
  assertType('string', s)
  local db2 = mockDb(true)   
  local stmt = db2:prepare[[ SELECT content FROM test WHERE id = :id ]]
  stmt:bind_names{id = 2}
  assertEqual(nil, stmt:first_row())

  db2:restore(s)
  assertEqual('Hello Lua', stmt:first_row()[1])   
end

test.all()
