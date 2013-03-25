#!/usr/bin/ruby

require 'sqlite3'

begin
    
  db = SQLite3::Database.open "ankipack.db"
  if db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='french_to_english'").empty?
    puts "french_to_english table not found... has it been created/generated yet?"
    puts "exiting ..."
    db.close
    exit
  end
  db.execute "DROP TABLE IF EXISTS french_to_english_fts"
  db.execute "CREATE VIRTUAL TABLE french_to_english_fts USING fts4(french, english)"
  db.execute "INSERT INTO french_to_english_fts(french, english) SELECT french, english FROM french_to_english"
    
rescue SQLite3::Exception => e 
    
  puts "Exception occured"
  puts e
    
ensure
  db.close if db
end

puts "all done!"
