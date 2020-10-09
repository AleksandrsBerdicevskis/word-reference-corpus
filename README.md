# word-reference-corpus
This repository contains the scripts and the data necessary to reproduce the results reported in 

Berdicevskis, Aleksandrs. Forthcoming 2020. Foreigner-directed speech is simpler than native-directed: Evidence from social media. In Proceedings of the Second Workshop on NLP and Computational Social Science @EMNLP.

## Corpus
The WordReference corpus itself may either be downloaded from LINK_COMING_SOON (the version scraped from the web in March 2019, the one analyzed in the paper) or directly scraped from the web (see download.rb below). In either case, you should end up with four tab-separated files (one per language), each containing seven tab-separated columns: message id, poster's nickname, poster' native language(s), the text of the message (post) itself, the id of the topic in response to which the message has been posted (0 if this message is the topic, i.e. the first in the thread), topicstarter's nickname ("topicstarter" if the poster is the topicstarter), native language of the topicstarter. These are the "raw" data with as little processing as possible (but http links and explicit quotes of other users' posts are removed during the download). If you want to create the version used in the paper (which means, inter alia, adding info about who is L1 and who is L2), you should use other scripts provided here.

## Scripts
Run all scripts as "ruby script.rb [PATH_to_INPUT] [PATH_TO_OUTPUT], see the first lines of the individual scripts for more info.

download.rb -- you may use this script to scrape the whole corpus from https://forum.wordreference.com/. Note that this may take several days, and that the download will sometimes crash for unknown reasons, you will have to restart it from where it stopped.

clean_symbols.rb -- this script removes (presumable) noise by filtering out all symbols that are not in the manually compiled accepted_symbols.txt. It also replaces all punctuation marks by " . " (to make it easier to count words). It uses files like "Italian.csv" as input and outputs "Italian_clean.csv".

process_corpus.rb -- this script adds info about the status (L1 or L2) of every speaker and the topicstarter. It uses files like "Italian_clean.csv" as input and outputs "Italian_clean2.csv". These "clean2" files are the version of the corpus that is used in the paper, and they contain two more columns as compared to the "raw" corpora: status (L1 or L2) of the speaker (column "ltype") and status of the topicstarter ("ts_type"). The script also outputs (as a separate file) a list of all native languages (exactly as provided by users) and whether they are labelled as L1 and L2 for a given language forum, you may check whether you are satisfied with the labelling.

data_analysis.rb -- this script prepares data for the statistical analysis reported in the paper. Thresholds and other parameters can be changed within the scripts. Rename "Italian_clean2.csv" (etc.) into "Italian.csv" and provide the path to these files. The files in the Data folder are the output of this script.

corpus_size.rb and count_topicstarters.rb are the auxiliary scripts whose functions are obvious from their names. They yield the numbers reported in the paper (for the "clean2" versions).

stats.r is an R script which performs the statistical analyses described in the paper and creates the figures. Set the threshold to the desired value in the script. Make sure the necessary packages (lmerTest etc) are installed, change the R directory to the Data folder so that the script can see its input.

## Data
This folder contains the output of data_analysis.rb (which is also the input for stats.r). The names of the files are to be read as follows:
[language]_[l1 vs l2 analysis (messages) or foreigner-directed-speech analysis (messagestowhom)]_[type of ttr (always "plain")]_[token threshold (100 or 200)]_[message threshold (how many messages must a speaker have posted in total (for l1 vs l2) or addressed to L1 and L2 (for foreigner directed speech), always 1]_[whether only the second message (first response) from every thread has to be included (always true)].csv. All the files are tab-separated.

If you have any questions, please contact me at aleksandrs.berdicevskis@gu.se.

2020-10-09