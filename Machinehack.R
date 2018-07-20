train<-Predicting.House.Prices.In.Bengaluru.Train.Data
test<-Predicting.House.Prices.In.Bengaluru.Test.Data
str(train)
summary(train)
# Checking missing values
sum(is.na(train))
# checking which variable has mising values
names<-colnames(train)
values<-t(colSums((is.na(train))))
NA_cols<-which(values>0)
values<-values[NA_cols]
NA_names<-names[NA_cols]
barplot(values[1:length(values)],horiz=TRUE,main="Missing Values",names.arg=NA_names,las=2)
# In barplot balcony and bath has missing value
str(train$bath)
str(train$balcony)
# removing the missing values
library(dplyr)
library(tidyr)
# replacing the missing values with mean for bath
x<-mean(train$bath, na.rm = TRUE)
train$bath<-train$bath %>% replace_na(x)
sum(is.na(train$bath))
# Balcony has around 600 missing values so removing this variable from dataset
train$balcony<-NULL
View(train)
# Feature Engineering
library(Boruta)
#Boruta gives significance of variables in dataset
boruta.train <- Boruta(price~., data = train, doTrace = 2)
boruta.train
plot(boruta.train, xlab = "", xaxt = "n")
lz<-lapply(1:ncol(boruta.train$ImpHistory),function(i)
  boruta.train$ImpHistory[is.finite(boruta.train$ImpHistory[,i]),i])
names(lz) <- colnames(boruta.train$ImpHistory)
Labels <- sort(sapply(lz,median))
axis(side = 1,las=2,labels = names(Labels),
       at = 1:ncol(boruta.train$ImpHistory), cex.axis = 0.7)

final.boruta <- TentativeRoughFix(boruta.train) # As we can see there is no tentative attributes
print(final.boruta) # so all the features are important 
getwd()
setwd("/home/mukut/Desktop")
write.csv(train, "training_data.csv")
write.csv(test, "test_data.csv")
# Now I am using H2O(open source) framework for fitting model
# you need following package to initiate h2o in your environment
# JVM should be installed on your machine before running following package
library(RCurl)
library(jsonlite)
library(h2o)
h2o.init()
df <- h2o.importFile(path = "/home/mukut/Desktop/training_data.csv")
df2 <- h2o.importFile(path = "/home/mukut/Desktop/test_data.csv")
rf1 <- h2o.randomForest(
  training_frame = df,
  validation_frame = df2,
  x = 1:7, 
  y = 8, 
  model_id = "rf_model",
  ntrees = 200,
  stopping_rounds = 2,
  seed = 1000000
)
rf1
gbm_model <- h2o.gbm(
  training_frame = df,
  validation_frame = df2,
  x = 1:7,
  y = 8,
  model_id = "gbm model",
  seed = 2000000
)
gbm_model
# Result with Random forest was better
# Now need to improve the accuracy further
# Hyperparameter tuning
rf_model2 <- h2o.randomForest( 
  training_frame = df,
  validation_frame = df2,
  x = 1:7,
  y = 8,
  model_id = "rf_final",
  ntrees = 200,
  max_depth = 30, # Increase depth, from 20
  stopping_rounds = 2,
  stopping_tolerance = 1e-2,
  score_each_iteration = TRUE,
  seed = 3000000 
)
# df = train data and df2 = test data
model_pred<-h2o.predict(rf_model2, newdata = df2)
#write.csv(model_pred, "Price_Prediction.csv")
# I have also used H2O flow to check the model behaviour 
# TO use H2O flow type in the browser localhost:54321 
# localhost:54321  you will get this address when you run h2o.init()