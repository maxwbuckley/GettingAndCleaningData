# Getting and Cleaning Data Assessment.


This is the markdown file for  the final assessment of the [Coursera Getting and Cleaning Data] course. The objective of this assessment is:

>To demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis.


The script run_analysis.R has several components. It is to be run from within the folder containing the top level of the samsung data. In my case the working directory was set as follows.


```r

setwd("~/R/Getting/final/UCI HAR Dataset")

```

The main part body of my code is as follows. It basically loads the several seperate files in the samsung dataset into one large dataset and returns that. In the process it also names all the variables sensibly.


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

This returns a 563 row , 10,299 column dataset. The column names being as follows. The first two columns Subject and Activity are factors. The subsequent 561 columns are continous floating point numbers.

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
 - and so on......

The activity labels corrected mapping is  as follows:

 - 1  WALKING
 - 2	WALKING_UPSTAIRS
 - 3	WALKING_DOWNSTAIRS
 - 4	SITTING
 - 5	STANDING
 - 6	LAYING


We read them into R and join them with  our datasubset using the following code:


```r

##Get the labels in prep for step 3 
activitylabels<-read.table("activity_labels.txt",stringsAsFactors=FALSE)

##Step 3
##I use this for joining my labels on. Rather than the whole table.
subset<-dataset[,1:2]
newlabels<-merge(subset,activitylabels,by.x=c("Activity"), by.y=c("V1"))

```

Now I select all the mean and standard deviation columns from the measurements and join them on my nicely labeled dataset above.

Then I use melt from the reshape2 library to convert my dataframe to long form.


```r

##Step 2.
##Here I extract only columns that have either the mean or standard deviation using a lovely grep
meandev<-dataset[,grep("std|mean", colnames(dataset))]


##Here I combine the mean and standard deviation columns with my Activity and Subject data to create my new dataset.
newdataset<-cbind(newlabels[,2:3],meandev)
colnames(newdataset)[2]<-"Activity"  

##Load the reshape2 library to get access to the melt function to convert my dataframe from wide to long form.
library("reshape2")
makelong<-melt(newdataset, id=c("Subject","Activity"))

```

At this point the object makelong has 813621 rows and 4 columns as follows.

 - Subject (Same as above)
 - Activity (A six level self explanatory labeled factor)
 - variable (A string explaining what variable the value field refers to.)
 - value (The value in question)
 
 
All that remains to do now is create my final output for the assignment. I do that using the final code snippet.


```r

##Step 5
##Here I use aggregate to find the average as per the instructions for step 5. 
aggdata<-aggregate(makelong$value, by=list(makelong$Subject,makelong$Activity,makelong$variable), FUN=mean)
colnames(aggdata)<-c("Subject","Activity","Variable","Mean")  

##This writes the output out
write.table(aggdata,"output.txt",row.names=FALSE)

```

This having the effect of aggregating the "variable" column for each Subject-Activity,Variable level combination. Effectively calculating an average for each. The final aggregate dataset having 14220 rows (6 Subjects * 30 Subjects * 79 original columns) and 4 columns .

 - Subject
 - Activity
 - Variable
 - Mean (The average value for that variable for that person for that activity state and for that measurement)
 

 
 
 
 
 
 
 
 
 
 [Coursera Getting and Cleaning Data]:https://www.coursera.org/course/getdata
 [family of different apply]:https://nsaunders.wordpress.com/2010/08/20/a-brief-introduction-to-apply-in-r/