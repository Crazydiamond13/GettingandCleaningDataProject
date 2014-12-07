path <- getwd()
setwd(path)

library(plyr)

#read subject_train, x_train, y_train files.
train.subj <- read.table(file = "./UCI HAR Dataset/train/subject_train.txt")
train.data <- read.table(file = "./UCI HAR Dataset/train/X_train.txt")
train.label <- read.table(file = "./UCI HAR Dataset/train/y_train.txt")

#read subject_test, x_test, y_train files.
test.subj <- read.table(file = "./UCI HAR Dataset/test/subject_test.txt")
test.data <- read.table(file = "./UCI HAR Dataset/test/X_test.txt")
test.label <- read.table(file = "./UCI HAR Dataset/test/y_test.txt")

#combine the subjects
all.subj <- rbind(train.subj, test.subj)
colnames(all.subj) <- "subject"
#combine the labels
all.label <- rbind(train.label, test.label)
#combine both train and test
all.data <- rbind(train.data,test.data)

#read features file and index for mean and std only.
features <- read.table(file = "./UCI HAR Dataset/features.txt")
colnames(features) <- c("feat.number", "feat.name")
ind.feat <- grep ("-(mean|std)\\(\\)",  features$feat.name)

#subset the columns of interest
sub.data <- all.data[,ind.feat]

#naming the columns in all.data according to features.
colnames(sub.data) <- features$feat.name[ind.feat]
colnames(sub.data) <- sub("\\(\\)", "", colnames(sub.data))
colnames(sub.data) <- sub("-", " ", colnames(sub.data))
colnames(sub.data) <- sub("-", " ", colnames(sub.data))
colnames(sub.data) <- sub("^t", "time", colnames(sub.data))
colnames(sub.data) <- sub("^f", "frequency", colnames(sub.data))

#read activity labels and clean the activity names
activity.label <- read.table(file = "./UCI HAR Dataset/activity_labels.txt")
colnames(activity.label) <- c("act.code", "act.name")
activity.label$act.name <- tolower(activity.label$act.name)
activity.label$act.name <- sub("_", " ", activity.label$act.name)

#replace the activities in the all.label column
new.label <- as.data.frame(activity.label[all.label[,1], 2])
colnames(new.label) <- "activity"

#merging final dataset
final.data <- cbind(all.subj, new.label, sub.data)

#use ddply() to split data by subjet, activity and apply colMeans to the rest of the columns to get means
tidy.data<- ddply(final.data, .(subject, activity), function(x) colMeans(x[, 3:66]))

write.table(tidy.data, file = "tidy_data.txt", row.names = FALSE)     
