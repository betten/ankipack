#!/usr/bin/ruby

require 'sqlite3'
require 'json'

# ARGV[0] - required, word frequency text file, expecting a word per line
# ARGV[1] - optional, number of randomly selected matches for a given word, defaults to 10

begin

  db = SQLite3::Database.open "ankipack.db"
  out = {}

  File.open(ARGV[0]).each_line do |word|
    matches = db.execute("SELECT DISTINCT french, english FROM french_to_english_fts WHERE french MATCH '#{word}'")
    out[word] = matches.sample(ARGV[1].to_i || 10)
  end

  write_to = "#{File.basename(ARGV[0], ".txt")}_with_examples.json"
  File.open(write_to, 'w') {|f| f.write(JSON.generate(out)) }

rescue SQLite3::Exception => e 
    
  puts "Exception occured"
  puts e
    
ensure
  db.close if db
end

puts "all done!"
