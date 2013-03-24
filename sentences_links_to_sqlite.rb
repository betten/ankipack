#!/usr/bin/ruby

require 'sqlite3'
require 'csv'

fra_sentences = []
eng_sentences = []

puts "starting sentences parse ..."

CSV.foreach('sentences.csv', { :col_sep => "\t", :quote_char => "{" }) do |row| 
  fra_sentences << row if row[1] == "fra"
  eng_sentences << row if row[1] == "eng"
end

puts "senteces parse complete ..."
puts "#{fra_sentences.count} fra sentences found, #{eng_sentences.count} eng sentences found"
puts "starting links parse ..."

fra_hash = {}
fra_sentences.each { |r| fra_hash[r[0]] = r[2] }
eng_hash = {}
eng_sentences.each { |r| eng_hash[r[0]] = r[2] }
fra_eng_sentences = []
fra_ids = fra_sentences.map { |r| r[0] }

CSV.foreach('links.csv', { :col_sep => "\t", :quote_char => "{" }) do |row| 
  unless fra_hash[row.first].nil? || eng_hash[row.last].nil?
    fra_eng_sentences << [fra_hash[row.first], eng_hash[row.last]]
  end
end

puts "links parse complete ..."
puts "#{fra_eng_sentences.count} fra > eng sentences"
puts "starting db create and insert ..."

begin
    
  db = SQLite3::Database.open "ankipack.db"
  db.execute "DROP TABLE IF EXISTS french_to_english"
  db.execute "CREATE TABLE french_to_english(id INTEGER PRIMARY KEY, french TEXT, english TEXT)"

  stmt = db.prepare("INSERT INTO french_to_english(french, english) VALUES(?, ?)")

  fra_eng_sentences.each do |fra_eng|
    stmt.execute(fra_eng[0], fra_eng[1])
  end
    
rescue SQLite3::Exception => e 
    
  puts "Exception occured"
  puts e
    
ensure
  stmt.close if stmt
  db.close if db
end

puts "all done!"
