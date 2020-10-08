#calculating the number of messages and speakers per subcorpus

STDERR.puts "Usage: ruby corpus_size.rb PATH-TO-CORPORA"

PATH = ARGV[0]


langs = ["Italian","French","Spanish","English"]


langs.each do |language|
    f = File.open("#{PATH}/#{language}.csv","r:utf-8")
    i = 0
    status = 0
    ntokens_l1 = 0.0
    ntokens_l2 = 0.0
    l1hash = {}
    l2hash = {}

    f.each_line do |line|
        if i % 10000 == 0
            STDERR.puts i
        end
        if i > 0
            
            line1 = line.strip.split("\t")
            message = line1[3]
            message = message.gsub(" . "," ")
            speaker = line1[1]
            ltype = line1[7]
            if ltype == "L1"
                ntokens_l1 += message.count(" ") 
                l1hash[speaker] = 1
            elsif ltype == "L2"
                ntokens_l2 += message.count(" ") 
                l2hash[speaker] = 1
            end
        end
        i += 1
    end
    STDOUT.puts "#{language} #{ntokens_l1} #{ntokens_l2} #{l1hash.keys.length} #{l2hash.keys.length}"
end
