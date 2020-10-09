#Removing (presumable) noise by filtering out all symbols that are not in the manually compiled accepted_symbols.txt

STDERR.puts "Usage: ruby clean_symbols.rb PATH-TO-CORPORA"

PATH = ARGV[0]

#process source files
#langs = ["English"]
langs = ["Italian","French","Spanish","English"]

symb = File.open("accepted_symbols.txt","r:utf-8")
symbolhash = {}
symb.each_line do |line|
  line1 = line.rstrip.split("\t")
  symbolhash[line1[0]] = line1[1]
end
symbolhash["\t"] = "1"

#STDOUT.puts symbolhash



langs.each do |lang|
  STDERR.puts lang
  f1 = File.open("#{PATH}\\#{lang}.csv","r:utf-8")
  fo = File.open("#{PATH}\\#{lang}_clean.csv","w:utf-8")
  f1.each_line.with_index do |line, index|
    STDERR.puts index
	if index > 0
	  line1 = ""
	  line = line.squeeze("?!.…") #squeeze sentence-end marks
	  line = line.gsub("’ "," ").gsub("´ "," ").gsub("‘ ", " ").gsub(" ’"," ").gsub(" ´"," ").gsub(" ‘", " ").gsub("' "," ").gsub(" '"," ") #remove non word-internal apostrophes
	  line_all = line.split("\t")
	  #take just the message, not speaker ids or native languages
	  line_all[3].each_char do |char|
	    case symbolhash[char]
		when "1"
		  line1 << char
		when "2"
		  line1 << " "
		when "3"
		  line1 << "."
		#when nil
		 # line
		end
	  end
	  line_all[3] = line1.gsub("."," . ").squeeze(" ").gsub(". .",".").gsub(". .",".").gsub(". .",".").squeeze(" ")
	  fo.puts line_all.join("\t")
	else
	  fo.puts line
	end
  end
  f1.close
  fo.close
end