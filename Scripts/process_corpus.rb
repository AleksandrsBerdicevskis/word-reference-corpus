#Adding info about the status (L1 or L2) of every speaker and the topicstarter. The script also output of all native languages (exactly as provided by users) and whether they are labelled as L1 and L2 for a given forum

STDERR.puts "Usage: ruby process_corpus.rb PATH-TO-CORPORA"

PATH = ARGV[0]

#langs = {"English"=>["EN","english"]}
langs = {"Italian"=>["IT","ital"],"French"=>["FR","franc","franç","fren"],"Spanish"=>["ES","span","castel","castil","spañ"],langs = {"English"=>["EN","english"]}

langs.each_pair do |lang,codes|
  langnamehash = {}
  f = File.open("#{PATH}\\#{lang}_clean.csv","r:utf-8")
  fo = File.open("#{PATH}\\#{lang}_clean2.csv","w:utf-8")
  fl = File.open("#{PATH}\\#{lang}_list.csv","w:utf-8")
  fo.puts "message_id\tnickname\tnative_language\tmessage\ttopic\ttopicstarter\tts_lang\tltype\tts_ltype"
  
  f.each_line.with_index do |line,index|
    if index > 0
      line1 = line.strip.split("\t")
	  ltype = ""
      langresponse = line1[2].gsub("\"","")
	  if !langnamehash[langresponse].nil? 
	    ltype = langnamehash[langresponse]
	  else
        if langresponse.include?(codes[0])	  
    	  ltype = "L1"
    	else
    	  codes[1..-1].each do |code|
    	    if langresponse.downcase.include?(code)
    		  ltype = "L1"
    		  break
    		end
    	  end
    	  if ltype != "L1"
    		ltype = "L2"
    	  end
    	end
    	fl.puts "#{langresponse}\t#{ltype}"
		langnamehash[langresponse] = ltype
	  end
	  ts_ltype = ""
	  STDERR.puts index
	  #STDERR.puts line1[5]
	  #STDERR.puts line1.length
	  ts_langresponse = line1[6].to_s.gsub("\"","")
	  if ts_langresponse != ""
	    ts_ltype = langnamehash[ts_langresponse]
      else
        line1 << ""
	  end
	  
	  
	  line1 << ltype
	  line1 << ts_ltype
	  fo.puts line1.join("\t")
	end
  end
  f.close
  fo.close
  fl.close
end