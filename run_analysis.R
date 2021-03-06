##This line is for clearning my environment
##rm(list=ls())
##Sets my path to the Directory in question
##setwd("~/R/Getting/final/UCI HAR Dataset")

##This function returns the completed dataset.
getCompleteDataset<-function(){
  
  ##This function takes a folder name either test or train and fetchs the data from that folder and subfolders
  getData<-function(folder){
    
    ##This function takes a folder and another argument type and simply returns the path to the relevant file.
    generateFilepath<-function(folder,type){
      filepath <- paste0(folder,"/",type,"_",folder,".txt")
      return(filepath)
    }
    
    ##Here we fetch all the relevant tables of data.
    subject<-read.table(generateFilepath(folder,"subject"))
    yvalues<-read.table(generateFilepath(folder,"y"))
    xvalues<-read.table(generateFilepath(folder,"X"))
    
    ##Here we fetch the column names.
    xvaluenames<-read.table("features.txt",stringsAsFactors=FALSE)
    
    ##Join the columns together
    outputframe<-cbind(subject,yvalues,xvalues)
    ##Append the two additional column names
    names<-c("Subject","Activity",xvaluenames[,2])
    ##Rename all the columns
    colnames(outputframe)<-names
    
    return(outputframe)
  }
  ###Now we simply load the relevant data and combine and return it.
  train<-getData("train")
  test<-getData("test")
  fullset<-rbind(train,test)
  
  return(fullset)
}


##Step 1 and Step 4 (The variable names are correctly set before data is returned)
##Load the data.
dataset<-getCompleteDataset()

##Get the labels in prep for step 3 
activitylabels<-read.table("activity_labels.txt",stringsAsFactors=FALSE)

##Step 3
##I use this for joining my labels on. Rather than the whole table.
subset<-dataset[,1:2]
newlabels<-merge(subset,activitylabels,by.x=c("Activity"), by.y=c("V1"))

##Step 2.
##Here I extract only columns that have either the mean or standard deviation using a lovely grep
meandev<-dataset[,grep("std|mean", colnames(dataset))]


##Here I combine the mean and standard deviation columns with my Activity and Subject data to create my new dataset.
newdataset<-cbind(newlabels[,2:3],meandev)
colnames(newdataset)[2]<-"Activity"  

##Load the reshape2 library to get access to the melt function to convert my dataframe from wide to long form.
library("reshape2")
makelong<-melt(newdataset, id=c("Subject","Activity"))

##Step 5
##Here I use aggregate to find the average as per the instructions for step 5. 
aggdata<-aggregate(makelong$value, by=list(makelong$Subject,makelong$Activity,makelong$variable), FUN=mean)
colnames(aggdata)<-c("Subject","Activity","Variable","Mean")  

##This writes the output out
write.table(aggdata,"output.txt",row.names=FALSE)
