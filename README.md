# Getting and Cleaning Data Assessment.

This is the markdown file for  the Getting and Cleaning Data Assessment. The objective is to explain how the associated scripts work. And the outputs.

The script run_analysis.R has several components. It is to be run from within the folder containing the toplevel samsung data. In my case set as follows.
```r

setwd("~/R/Getting/final/UCI HAR Dataset")

```

The main part body of my code is as follows. It basically loads the several seperate files in the samsung dataset into one large. dataset.

```r

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

```

This returns a 563 row , 10,299 column dataset. The column names being as follows and so on.

 - Subject (A number refering the subject the observations were made on)
 - Activity (A number refering the the activity level replaced with a word descrption later)
 - tBodyAcc-mean()-X
 - tBodyAcc-mean()-Y
 - tBodyAcc-mean()-Z
 - tBodyAcc-std()-X
 - tBodyAcc-std()-Y
 - tBodyAcc-std()-Z
 - tBodyAcc-mad()-X
 - tBodyAcc-mad()-Y
 - tBodyAcc-mad()-Z
 - tBodyAcc-max()-X
 - ......

The activity labels mapping as follows

 - 1  WALKING
 - 2	WALKING_UPSTAIRS
 - 3	WALKING_DOWNSTAIRS
 - 4	SITTING
 - 5	STANDING
 - 6	LAYING


We read them in and join them with the following code.

```r

##Get the labels in prep for step 3 
activitylabels<-read.table("activity_labels.txt",stringsAsFactors=FALSE)

##Step 3
##I use this for joining my labels on. Rather than the whole table.
subset<-dataset[,1:2]
newlabels<-merge(subset,activitylabels,by.x=c("Activity"), by.y=c("V1"))

```

Now I calculate the means and standard deviatons of the measurements (row summaries). And join them on my nicely labeled dataset above.

```r

##Step 2.
##Here I calculate the mean and stddev for all the measurements.
means<-apply(dataset[,3:length(dataset)],1,FUN=mean)
stds<-apply(dataset[,3:length(dataset)],1,FUN=sd)
    

##Here I combine them together to create my new dataset.
newdataset<-cbind(newlabels[,2:3], means, stds)
##Just need to add some pretty column names.
colnames(newdataset)<-c("Subject","Activity","Mean","StdDev")  

```

At this point newdataset has 10,299 rows and 4 columns as follows.

 - Subject (Same as above)
 - Activity (A six level self explanatory factor)
 - Mean (The average of the previous 561 numerical values)
 - StdDev (The standard deviation of the previous 561 numerical values)
 
 
All that remains to do now is create my final output for the assignment. I do that using the final code snippet.

```r

##Step 5
##Here I use aggregate to find the average as per the instructions for step 5. 
aggdata<-aggregate(newdataset$Mean, by=list(newdataset$Subject,newdataset$Activity), FUN=mean)
colnames(aggdata)<-c("Subject","Activity","Mean")  

##This writes the output out
write.table(aggdata,"output.txt",row.names=FALSE)

```

This having the effect of aggregating the mean column for each Subject Activity level pair. Effectively calculating an average of averages. The final aggregate dataset having 180 rows (6 Subjects * 30 Subjects) and 3 columns .

 - Subject
 - Activity
 - Mean
 
 
 
 
 
 
 
 
 
 
 