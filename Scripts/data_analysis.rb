#preparing data for the statistical analysis reported in the paper. Thresholds and other parameters can be changed below

STDERR.puts "Usage: ruby data_analysis.rb PATH-TO-CORPORA OUTPUT-PATH"

PATH = ARGV[0]
OUTPATH = ARGV[1]

#langs = ["English"]
langs = ["Italian","French","Spanish","English"]
@threshold = 100 #n first tokens upon which the TTR will be calculated
@type = "plain" #plain ttr (as in the article) or "sliding_window" (=moving-average TTR)
@only_second = true #take just the second message (as in the article) or the whole thread
#threshold_msgs = 10
threshold_msgs_to = 1 #for L1 vs L2 speaker analysis: exclude speakers that have authored less messages than the threshold (currently at the minimum); for foreigner-directed-speech analysis: include only speakers that have authored at least as many messaged addressed to L1 and at least as many addressed to L2


#messages = {"ttr"=>0.0, topic => "", speaker = ""}
#speakers = {"ave"=>0.0, "ttrs"=> [], "nmessages"=> 0.0, "lang" => "", "ltype" = > "", "se" => 0.0}
speakers = Hash.new{|hash,key| hash[key] = Hash.new()}
messages = Hash.new{|hash,key| hash[key] = Hash.new()}
threads = Hash.new{|hash,key| hash[key] = Hash.new()}

def sd(array)
    if array.length > 1
        sum = 0.0
        for i in 0..array.length-1
            sum += array[i]
        end
        mean = sum/array.length.to_f
        numerator = 0.0
        for i in 0..array.length-1
            numerator += (array[i]-mean) ** 2
        end
        sd = Math.sqrt(numerator/(array.length-1))
    else
        sd = 0.0
    end
    return sd
end

def se(array)
    if array.length > 1
        se = sd(array)/Math.sqrt(array.length)
    else
        se = 0.0
    end
    return se
end


def sumarray(array)
    sum = 0.0
    array.each do |element|
        sum += element
    end
    sum
end

def calculate_ttr(message)
    ttr = 0.0
    
    nwords = message.count(" ") + 1
    sum    = 0.0
    n = 0.0
    
    if @type == "sliding_window"
        for lower in 0..nwords - @threshold do
            upper = lower + @threshold - 1
            extract = message.split(" ")[lower..upper]
            tokens = extract.length.to_f 
            types = extract.uniq.length.to_f 
            sum += types/tokens
            n += 1
        end
    else
        extract = message.split(" ")[0..@threshold-1]
        tokens = extract.length.to_f 
        types = extract.uniq.length.to_f 
        ttr = types/tokens
    end
    
    return ttr
end 

langs.each do |language|
    f = File.open("#{PATH}/#{language}.csv","r:utf-8")
    i = 0
    status = 0

    om = File.open("#{OUTPATH}/#{language}_messagestowhom_ttr#{@type}_tokenthr#{@threshold}_msgthr#{threshold_msgs_to}_onlysecond#{@only_second.to_s}.csv","w:utf-8")
    om2 = File.open("#{OUTPATH}/#{language}_messages_ttr#{@type}_tokenthr#{@threshold}_msgthr#{threshold_msgs_to}.csv","w:utf-8")
    om2.puts "message_id\tttr\tspeaker\tlang\tltype"
    om.puts "message_id\tttr\tspeaker\tlang\tltype\ttopic\ttopicstarter\ttopicstarter_lang\ttopicstarter_ltype"
    
    f.each_line do |line|
        if i % 1000 == 0
            STDERR.puts i
        end
        if i > 0
            
            line1 = line.strip.split("\t")
            message = line1[3]
            message = message.gsub(" . "," ")
            id = line1[0]
            #STDERR.puts id
            speaker = line1[1]
            #STDERR.puts speaker
            lang = line1[2]
            topic = line1[4]
            if topic == "0" 
                status = 1 
            elsif
                status += 1
            end
            ts = line1[5]
            ts_lang = line1[6]
            ltype = line1[7]
            #STDERR.puts ltype
            ts_ltype = line1[8]
            #if i==2
            #    break
            #end
            if message.count(" ") >= @threshold 
                
                ttr = calculate_ttr(message)
                messages[id]["ttr"] = ttr
                messages[id]["topic"] = topic
                messages[id]["speaker"] = speaker
                om2.puts "#{id}\t#{ttr}\t#{speaker}\t#{lang}\t#{ltype}"
                
                if speakers[speaker]["ttrs"].nil?
                    speakers[speaker]["ttrs"] = [ttr]
                    speakers[speaker]["nmessages"] = 1
                    speakers[speaker]["lang"] = lang
                    speakers[speaker]["ltype"] = ltype
                    speakers[speaker]["hasfreq"] = true
                    speakers[speaker]["ttrs_to"] = Hash.new{|hash,key| hash[key] = Array.new()}
                    speakers[speaker]["nmessages_to"] = Hash.new(0.0)

                    
                    #if ts_ltype == "L1"
                    #    speakers[speaker]["ttrs_to_l1"] = [ttr]
                    #    speakers[speaker]["nmessages_to_l1"] = 1
                    #elsif ts_ltype == "L2"
                    #    speakers[speaker]["ttrs_to_l2"] = [ttr]
                    #    speakers[speaker]["nmessages_to_l2"] = 1
                    #end
                else
                    speakers[speaker]["ttrs"] << ttr    
                    speakers[speaker]["nmessages"] += 1
                    #if (status ==2 or !@only_second)
                    #    speakers[speaker]["ttrs_to"][ts_ltype] << ttr
                    #    speakers[speaker]["nmessages_to"][ts_ltype] += 1
                    #end
                    #if ts_ltype == "L1"
                    #    speakers[speaker]["ttrs_to_l1"] << ttr
                    #    speakers[speaker]["nmessages_to_l1"] += 1
                    #elsif ts_ltype == "L2"
                    #    speakers[speaker]["ttrs_to_l2"] << ttr
                    #    speakers[speaker]["nmessages_to_l2"] += 1
                    #end
                end
                if (status == 2 or !@only_second)
                    speakers[speaker]["ttrs_to"][ts_ltype] << ttr
                    speakers[speaker]["nmessages_to"][ts_ltype] += 1
                    om.puts "#{id}\t#{ttr}\t#{speaker}\t#{lang}\t#{ltype}\t#{topic}\t#{ts}\t#{ts_lang}\t#{ts_ltype}"
                end



                
                 
                
                #if topic == "0" 
                #    threads[id]["nmessages"] = 1
                #else
                if topic != "0"
                    if speaker != messages[topic]["speaker"]
                        #threads[topic]["nmessages"] += 1
                        if threads[topic][speaker].nil?
                            threads[topic][speaker] = {}
                            threads[topic][speaker]["ncontribs"] = 1
                            threads[topic][speaker]["ttrs"] = [ttr]
                            #threads[topic][speaker]["ave"] = 0.0
                        else
                            threads[topic][speaker]["ncontribs"] += 1
                            threads[topic][speaker]["ttrs"] << ttr
                        end
                    end
                end
            else
                speakers[speaker]["lang"] = lang
                speakers[speaker]["ltype"] = ltype
                #speakers[speaker]["hasfreq"] = TRUE
                if topic == "0"
                    messages[id]["ttr"] = "na"
                    messages[id]["topic"] = topic
                    messages[id]["speaker"] = speaker
                end
                
            
            end #if message length >= threshold end
        end #if i > 0 end
        i += 1
    end
    
    
    speakers.each_value do |speakerhash|
        if speakerhash["hasfreq"]
            if speakerhash["nmessages"] >= threshold_msgs_to
                speakerhash["ave"] = sumarray(speakerhash["ttrs"])/speakerhash["nmessages"]
                speakerhash["se"] = se(speakerhash["ttrs"])
            end
            if speakerhash["nmessages_to"]["L1"] >= threshold_msgs_to and speakerhash["nmessages_to"]["L2"] >= threshold_msgs_to
                speakerhash["ave_to_l1"] = sumarray(speakerhash["ttrs_to"]["L1"])/speakerhash["nmessages_to"]["L1"]
                speakerhash["se_to_l1"] = se(speakerhash["ttrs_to"]["L1"])
                speakerhash["ave_to_l2"] = sumarray(speakerhash["ttrs_to"]["L2"])/speakerhash["nmessages_to"]["L2"]
                speakerhash["se_to_l2"] = se(speakerhash["ttrs_to"]["L2"])
            end
        end
    end
    threads.each_value do |threadhash|
        threadhash.each_value do |sthash|
            sthash["ave"] = sumarray(sthash["ttrs"])/sthash["ncontribs"]
        end
    end


    os = File.open("#{OUTPATH}/#{language}_speakerstowhom_ttr#{@type}_tokenthr#{@threshold}_msgthr#{threshold_msgs_to}_onlysecond#{@only_second.to_s}.csv","w:utf-8")
    os2 = File.open("#{OUTPATH}/#{language}_speakers_ttr#{@type}_tokenthr#{@threshold}_msgthr#{threshold_msgs_to}.csv","w:utf-8")
    #os.puts "speaker\tlang\tltype\tave_ttr\tse\tnmessages\tave_ttr_to_l1\tse_to_l1\tnmessages_to_l1\tave_ttr_to_l2\tse_to_l2\tnmessages_to_l2\tto_l1_minus_to_l2"
    os.puts "speaker\tlang\tltype\tave_ttr\tse\tnmessages\tto_whom"
    os2.puts "speaker\tlang\tltype\tave_ttr\tse\tnmessages"
    speakers.each_pair do |id,hash|
        if hash["hasfreq"] and hash["nmessages_to"]["L1"] >= threshold_msgs_to and hash["nmessages_to"]["L2"] >= threshold_msgs_to
            #os.puts "#{id}\t#{hash["lang"]}\t#{hash["ltype"]}\t#{hash["ave"]}\t#{hash["se"]}\t#{hash["nmessages"]}\t#{hash["ave_to_l1"]}\t#{hash["se_to_l1"]}\t#{hash["nmessages_to"]["L1"]}\t#{hash["ave_to_l2"]}\t#{hash["se_to_l2"]}\t#{hash["nmessages_to"]["L2"]}\t#{hash["ave_to_l1"] - hash["ave_to_l2"]}"
            os.puts "#{id}\t#{hash["lang"]}\t#{hash["ltype"]}\t#{hash["ave_to_l1"]}\t#{hash["se_to_l1"]}\t#{hash["nmessages_to"]["L1"]}\tto_L1"
            os.puts "#{id}\t#{hash["lang"]}\t#{hash["ltype"]}\t#{hash["ave_to_l2"]}\t#{hash["se_to_l2"]}\t#{hash["nmessages_to"]["L2"]}\tto_L2"
            os2.puts "#{id}\t#{hash["lang"]}\t#{hash["ltype"]}\t#{hash["ave"]}\t#{hash["se"]}\t#{hash["nmessages"]}"
        end
    end

end
