##rm(list=ls())

##setwd("~/R/Getting/final/UCI HAR Dataset")

getCompleteDataset<-function(){
  
  getData<-function(folder){
    
    generateFilepath<-function(folder,type){
      filepath <- paste0(folder,"/",type,"_",folder,".txt")
      return(filepath)
    }
    
    subject<-read.table(generateFilepath(folder,"subject"))
    yvalues<-read.table(generateFilepath(folder,"y"))
    xvalues<-read.table(generateFilepath(folder,"X"))
    
    xvaluenames<-read.table("features.txt",stringsAsFactors=FALSE)
    
    outputframe<-cbind(subject,yvalues,xvalues)
    names<-c("Subject","Activity",xvaluenames[,2])
    colnames(outputframe)<-names
    
    return(outputframe)
  }
  train<-getData("train")
  test<-getData("test")
  fullset<-rbind(train,test)
  
  return(fullset)
}

dataset<-getCompleteDataset()

activitylabels<-read.table("activity_labels.txt",stringsAsFactors=FALSE)

#activitylabels$V2[dataset$Activity==activitylabels$V1]
##I use this for joining my labels on.
subset<-dataset[,1:2]
newlabels<-merge(subset,activitylabels,by.x=c("Activity"), by.y=c("V1"))

##Here I calculate the mean and stddev for all the measurements.
means<-apply(dataset[,3:length(dataset)],1,FUN=mean)
stds<-apply(dataset[,3:length(dataset)],1,FUN=sd)
    
##Here I combine them together to create my new dataset.
newdataset<-cbind(newlabels[,2:3], means, stds)
##Just need to add pretty column names.
colnames(newdataset)<-c("Subject","Activity","Mean","StdDev")  

aggdata<-aggregate(newdataset$Mean, by=list(newdataset$Subject,newdataset$Activity), FUN=mean)
colnames(aggdata)<-c("Subject","Activity","Mean")  

##This writes the output out
write.table(aggdata,"output.txt",row.names=FALSE)
