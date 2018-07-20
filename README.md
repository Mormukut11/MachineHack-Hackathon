# MachineHack-Hackathon

I have solved the problem in the following way:

1) Load the data in RStudio.
2) Perform EDA 
3) Check the missing values in the dataset
4) for bath replace the missing value with mean and remove the balcony from dataset because it contains large no of missing values
5) Perform feature engineering using Boruta package in R
6) I have used H2O package for fitting the model.
7) Fit the model with gbm and randomforest but randomforest performed better so keep the result of randomforest.
8) Perform Hyperparameter Tuning to improve the accuracy of model.
9) Predict the prices
10) Accuracy 86.8

# See the code for more details
