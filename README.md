# Bellabeat_Analysis
Google Capstone Project

##### Author: Pooja

##### Date: July 19, 2024

#

_The six steps in data analysis process:_
### ❓ [Ask](#1-ask)
### 💻 [Prepare](#2-prepare)
### 🛠 [Process](#3-process)
### 📊 [Analyze](#4-analyze)
### 📋 [Share](#5-share)
### 🧗‍♀️ [Act](#6-act)

# Background
Bellabeat is a high-tech manufacturer of smart health devices for women. They have tasked you with analyzing their device usage data and provide recommendations to the marketing team.

# The Ask Phase
The purpose of data analytics is to uncover patterns from the data gathered and to make business decisions based on those patterns identified. But, in order to do this, we must define the problem statement.

💡 **BUSINESS TASK: Analyze Fitbit data to gain insight and help guide marketing strategy for Bellabeat to grow as a global player.**

Primary stakeholders: Urška Sršen and Sando Mur, executive team members.

Secondary stakeholders: Bellabeat marketing analytics team.

## The Preprare Phase

Data Source: 30 participants FitBit Fitness Tracker Data from Mobius: https://www.kaggle.com/arashnic/fitbit. The dataset has 18 CSV files. 

The ROCCC analysis:
The data is Reliable and Original. However, the sample size is 30. There are a lot of inconsistencies and errors. The weight CSV file is incomplete and has data only for few people. The dataset is recorded for a period of 1 month in 2016. The data is not current. 

## The Process Phase

I did the following preprocessing steps on the data in an Excel Sheet using PowerQuery:

- Removed Duplicates
- Consistent Naming across different files
- Checked for data types of all columns
- Created a new column to calculate Average time in Bed not asleep using existing columns
- Merged all relevant data into a single file and named it the "final_df"

Load data into R STudio, install libraries and view the summary statistics of the dataset:

```
library(tidyverse)
library(kableExtra)  
library(scales)   
library(highcharter) 
library(RColorBrewer)  
library(lubridate)
```
To view the dataset
```
view(FInal_df)
head(FInal_df)
```
To remove null values 
```
final_df <- FInal_df %>%
  distinct() %>%
  drop_na()
```
To see summary statistics of the dataset
```
summary(FInal_df)
```
## The Analyze Phase
[Back to Top](#Author-Pooja)
```
final_df %>%  
  select(TotalSteps,
         TotalDistance,
         SedentaryMinutes, Calories) %>%
  summary()
```
High-Level Insights:
- Average steps taken by the sample dataset is ~8100 steps in a day
- Average distance covered in a day stood at 5.72 kms
- Sedentary time spent on an average was 799 minutes (~13 hours)- I guess this included the sleeping time as well
- Average calories consumed in a day was 2323.

1. Steps vs Calories: I have tried to analyse the dataset to see the relation between steps taken in a day and the calories consumed.
```
final_df %>% 
  group_by(TotalSteps, Calories) %>% 
  ggplot(aes(x = TotalSteps, y = Calories, color = Calories)) +
  geom_point() +
  geom_smooth() + 
  theme(legend.position = c(.8, .3),
        legend.spacing.y = unit(1, "mm"), 
        panel.border = element_rect(colour = "black", fill=NA),
        legend.background = element_blank(),
        legend.box.background = element_rect(colour = "black")) +
  labs(title = 'Calories burned by total steps taken',
       y = 'Calories',
       x = 'Total Steps',
       caption = 'Data Source: FitBit Fitness Tracker Data')
```
![Plot-1](https://github.com/user-attachments/assets/0cc9901e-1753-4f11-8202-98069862e43f)



 

