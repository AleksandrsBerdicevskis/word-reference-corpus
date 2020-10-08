#Downloading the forum data. Sometimes the download crashes for unknown reasons and has to be restarted manually from the page where it stopped. This can be done adjusting the "pagelinks" hash, see the commented lines 125-130. Quotes and http links are removed.

require 'rubygems'
require 'nokogiri'
require 'open-uri'
PREFIX = "https://forum.wordreference.com/"
#NOWAY = {"Spanish"=>["https://forum.wordreference.com/threads/poto.450197/"], "French" =>["https://forum.wordreference.com/threads/prenoms-de-fleurs.498968/"],"English"=>[]}
NOWAY = {"Spanish"=>["450197","286089"], "French" =>["498968","186360"],"English"=>[]}

TNOWAY = {"Spanish"=>["277923","273722","278631","268631","278442","277829","287252","278053","270421"], "French" =>["504682","505639","505175","452634","506005","505338","497052","504888","505198","497820","505624","505505","505184","504865","504040","501178","504658","504377","503451","504767","503052","501951","502829","500496","501307","501340","499959","501397","493448","499226","498065","499071"],"English"=>[]} #This is needed solely since I am restarting French from page720
@langhash = {}

def getthreadindex(href)
  index = href[href.rindex(".")+1..-2]
  return index
end

def getthreadhrefs(page)
  hrefarray = []
  page.css('h3[class="title"] a').each do |a|
    hrefarray << "#{PREFIX}#{a["href"]}"
  end
  return hrefarray
end

def clean(text)
  text = text.gsub("\t"," ").gsub("\r"," ").gsub("\n"," ").squeeze(" ").gsub("\<","")
  return text
end

def processthreadpage(page,file,filelang)
  lis = page.css('li').to_a
  #usertexts = page.css('h3[class="userText"] a').to_a #Could be used to sanity check usernames and native languages, but the latter requires logging in, the former does not seem necessary
  nativelangs = page.css('dd[title="Native language"]').to_a 
  liindex = 0
  lis.each do |li| #process one post (message)
    if li["class"].to_s[0..7]==("message ")
      nickname = li["data-author"] 
	  #STDERR.puts nickname
	  #STDERR.puts nativelangs[liindex].text
	  
	  if @langhash[nickname].nil? #store native languages for processed members, should be faster
        #STDERR.puts "Not stored"
		currentlang = nativelangs[liindex].text
		#if !@langhash.values.include?(currentlang)
		#  filelang.puts currentlang
		#end
		@langhash[nickname] = currentlang
		
      end	  
  	  id = li["id"].delete("-") #message id 
	  
  	  message = page.css("div[id=#{id}] blockquote")
  	  message2 = page.css("div[id=#{id}] div") #used to get rid of quotes
  	  theysaid = [] #this piece helps getting rid of "AAA said..."
  	  message2.each do |m2|
  	    if m2['class']=="attribution type"
  	      theysaid << clean(m2.text)
  	    end
  	  end
  	  messagetext = ""
  	  message.each do |m|
  	    if m['class'] == "messageText SelectQuoteContainer ugc baseHtml"
  		  messagetext = clean(m.text)
  	    end
  	    if m['class'] == "quoteContainer"
		  quotetext = clean(m.text)
		  theysaid.each do |said| #we cannot know exactly who is being quoted (there are non-attributed quotes, several quotes  within one message are possible, so we'll just loop through the whole array of "AAA said...", expensive as it is
  		    if messagetext.include?(said)
  		      messagetext = messagetext.gsub(said,"")
  		    end
			if quotetext.include?(said) #clean quote as well to make quote and message identical. Important for quotes within quotes
			  quotetext = quotetext.gsub(said,"")
			end
  		  end
		  messagetext = messagetext.gsub(quotetext,"") #get rid of the quote
  	    end
  	  end
  	  
	  #removing everything that begins with http://
	  messagewords = messagetext.split(" ")
	  messagewords.each do |word|
	    if word[0..3] == "http"
		  messagewords.delete(word)
		end
	  end
	  messagetext = messagewords.join(" ")
	  
	  file.puts "#{id}\t#{nickname}\t#{@langhash[nickname]}\t#{messagetext}"
  	  liindex += 1
    end
  end
  if !page.css('link[rel="next"]').empty? #does the thread have more pages?
	href = page.css('link[rel="next"]')[0]["href"]
	page = Nokogiri::HTML(open("#{PREFIX}#{href}",{ssl_verify_mode: 0}))
	processthreadpage(page,file,filelang)
  end
end

def getmessages(hrefarray,file,filelang,langname) 
  hrefarray.each.with_index do |href,index| #process one thread
    STDERR.puts href #multi-page threads get only one href outputted. Can be changed if this line is moved to processthreadpage, but that's hardly necessary
	#file.puts href #for tracing
	
	if !NOWAY[langname].include?(getthreadindex(href)) and !TNOWAY[langname].include?(getthreadindex(href))
	  page = Nokogiri::HTML(open(href,{ssl_verify_mode: 0}))
	  processthreadpage(page,file,filelang)
	else  
	  STDERR.puts "Skip this thread"
	end
	
	##if index == 1	#for testing purposes. Limits the number of threads to be processed
	##  break
	##end
  end
end

#check again Click to expand and remove manually
#http after other things than spaces are not removed. 
#remaining issues: strikethroughs, foreign words, special symbols
#separate script: sort languages into native/non-native, count speakers of every type for every subcorpus


pagelinks = {"forums/solo-italiano.51/"=>"Italian", "forums/francais-seulement.46/"=>"French", "forums/solo-espanol.45/"=>"Spanish", "forums/english-only.6/"=>"English"}
#pagelinks = {"forums/solo-italiano.51/"=>"Italian"}
#pagelinks = {"forums/francais-seulement.46/"=>"French","forums/solo-espanol.45/"=>"Spanish","forums/english-only.6/"=>"English"}
#pagelinks = {"forums/francais-seulement.46/page-720"=>"French","forums/solo-espanol.45/"=>"Spanish","forums/english-only.6/"=>"English"} #for restaring French
#pagelinks = {"forums/solo-espanol.45/page-1328"=>"Spanish","forums/english-only.6/"=>"English"} #for restaring Spanish where it broke
#pagelinks = {"forums/francais-seulement.46/page-787"=>"French"}
#pagelinks = {"forums/english-only.6/page-9232"=>"English"}

 
#why 205 for Italian?
pagelinks.keys.each do |pagelink|
  file = File.new("#{pagelinks[pagelink]}.csv","w:utf-8") #open file for the given language
  filelang = File.new("#{pagelinks[pagelink]}_langs.txt","w:utf-8")
  file.puts "message_id\tnickname\tnative_language\tmessage"
  nextlink = [{"href"=>pagelink}]
  begin #loop commented out ## to for testing purposes
    STDERR.puts nextlink[0]["href"] #outputs page
	page = Nokogiri::HTML(open("#{PREFIX}#{nextlink[0]["href"]}",{ssl_verify_mode: 0}))
	getmessages(getthreadhrefs(page),file, filelang, pagelinks[pagelink])
	nextlink = page.css('link[rel="next"]') #move to next page
  end until nextlink.empty?
  
  file.close
  filelang.close
end

#ff = File.new("languages.txt","w:utf-8")
#@langhash.values.uniq.each do |lang|
#  ff.puts lang
#end
