#calculating the number of L1 and L2 topicstarters

STDERR.puts "Usage: ruby count_topicstarters.rb PATH-TO-CORPORA"

PATH = ARGV[0]

["Italian", "French", "Spanish", "English"].each do |language|
    l1 = 0
    l2 = 0
    datafile = File.open("#{PATH}\\#{language}.csv","r:utf-8")
    datafile.each_line do |line|
        line1 = line.split("\t")
        if line1[5] == "topicstarter"
            if line1[7] == "L1"
                l1 += 1
                if language == "English"
                    STDOUT.puts line
                end 
            elsif line1[7] == "L2"
                l2 += 1
            end

        end
    end
    datafile.close
    STDERR.puts "#{language}\t#{l1}\t#{l2}\t#{l2.to_f/(l1+l2)}"
end