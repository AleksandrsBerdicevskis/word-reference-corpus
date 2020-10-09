#performing the statistical analyses described in the paper and creating the figures. Set threshold to the desired value below. Make sure the necessary packages (lmerTest etc) are installed, change the R directory to the Data folder.

library(lmerTest)
library(effsize)
library(ggplot2)
library(gridExtra)

langs <- c("Italian", "French","Spanish", "English")
threshold <- 200
for (lang in langs){
    print(lang)
    dataset <- read.csv(paste(lang, "_messages_ttrplain_tokenthr", threshold, "_msgthr1.csv", sep = ""),header=TRUE,sep="\t",dec=".",quote="")
    dataset$ltype <- as.factor(dataset$ltype)
    print("l1 vs l2")
    print(summary(lmer(ttr ~ ltype + (1|speaker) , data = dataset)))
    #boxplot(dataset[dataset$ltype == "L1",]$ttr, dataset[dataset$ltype == "L2",]$ttr)
    
    print("FDS")
    dataset2 <- read.csv(paste(lang, "_messagestowhom_ttrplain_tokenthr", threshold, "_msgthr1_onlysecondtrue.csv", sep = ""),header=TRUE,sep="\t",dec=".",quote="")
    dataset2a <- dataset2[dataset2$ltype == "L1",]
    dataset2b <- dataset2[dataset2$ltype == "L2",]
    print(summary(lmer(ttr ~ ltype * topicstarter_ltype + (1|speaker), data = dataset2)))
    
    if (lang == "Italian"){
      p1 <- ggplot(dataset, aes(x=ltype, y=ttr, fill=ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Speaker status")
      b1 <- ggplot(dataset2a, aes(x=topicstarter_ltype, y=ttr, fill=topicstarter_ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Topicstarter status")
      c1 <- ggplot(dataset2b, aes(x=topicstarter_ltype, y=ttr, fill=topicstarter_ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Topicstarter status")
    }
    if (lang == "French"){
      p2 <- ggplot(dataset, aes(x=ltype, y=ttr, fill=ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Speaker status")
      b2 <- ggplot(dataset2a, aes(x=topicstarter_ltype, y=ttr, fill=topicstarter_ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Topicstarter status")
      c2 <- ggplot(dataset2b, aes(x=topicstarter_ltype, y=ttr, fill=topicstarter_ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Topicstarter status")
    }
    if (lang == "Spanish"){
      p3 <- ggplot(dataset, aes(x=ltype, y=ttr, fill=ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Speaker status")
      b3 <- ggplot(dataset2a, aes(x=topicstarter_ltype, y=ttr, fill=topicstarter_ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Topicstarter status")
      c3 <- ggplot(dataset2b, aes(x=topicstarter_ltype, y=ttr, fill=topicstarter_ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Topicstarter status")
    }
    if (lang == "English"){
      p4 <- ggplot(dataset, aes(x=ltype, y=ttr, fill=ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Speaker status")
      b4 <- ggplot(dataset2a, aes(x=topicstarter_ltype, y=ttr, fill=topicstarter_ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Topicstarter status")
      c4 <- ggplot(dataset2b, aes(x=topicstarter_ltype, y=ttr, fill=topicstarter_ltype)) + geom_violin(trim=FALSE) + geom_boxplot(width = 0.1) + theme(legend.position="none") + ggtitle(lang) + xlab("Topicstarter status")
    }
    
    
}

grid.arrange(p1,p2,p3,p4)
dev.new()
grid.arrange(b1,b2,b3,b4)
dev.new()
grid.arrange(c1,c2,c3,c4)