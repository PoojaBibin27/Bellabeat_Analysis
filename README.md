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

1. Steps vs Calories: I have tried to analyse the dataset to see the relation between steps taken in a day and the calories burnt.
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

Correlation Coefficient : 0.45 (Mild Positive Correlation)
Insight: The more steps one takes the higher the amount of calories burnt!
```
cor.test(final_df$TotalSteps, final_df$Calories, method = 'pearson', conf.level = 0.95)
```
2. Steps taken each day of the week
```
weekday_steps <- final_df %>%
  mutate(weekday = weekdays(Date))
weekday_steps$weekday <-ordered(weekday_steps$weekday, levels=c("Monday", "Tuesday", "Wednesday", "Thursday",
                                                                "Friday", "Saturday", "Sunday"))
weekday_steps <-weekday_steps %>%
  group_by(weekday) %>%
  summarize (daily_steps = mean(TotalSteps))

head(weekday_steps)
```
```
ggplot(weekday_steps, aes(weekday, daily_steps)) +
  geom_col(fill = "#d62d58") +
  geom_hline(yintercept = 7500) +
  labs(title = "Daily steps per weekday", x= "", y = "") +
  theme(axis.text.x = element_text(angle = 45,vjust = 0.5, hjust = 1))
```
![Plot-2](https://github.com/user-attachments/assets/493b88d2-7d5a-4d60-b941-277af2869674)

3. Intensity of Activity through the week
```
final_df %>% 
  select(VeryActiveDistance, 
         ModeratelyActiveDistance, 
         LightActiveDistance) %>% 
  summarise(across(everything(), list(sum))) %>% 
  gather(activities, value) %>% 
  mutate(ratio = value / sum(value),
         label = percent(ratio %>% round(4))) %>% 
  mutate(activities = factor(activities, 
                             labels = c('Light Activity','Moderate Activity', 'Heavy Activity'))) %>% 
  ggplot(aes(x = (activities), 
             y = value, 
             label = label, 
             fill = activities)) +
  geom_bar(stat='identity') +
  geom_label(aes(label = label), 
             fill = "beige", 
             colour = "black",
             vjust = 0.5) +
  scale_fill_brewer(palette="Accent") +
  theme(legend.position="none") +
  labs(
    title = "Intensity of exercise activity",
    x = "Activity level",
    y = "Distance",
    caption = 'Data Source: FitBit Fitness Tracker Data'
)
```
![Plot-4](https://github.com/user-attachments/assets/d8897514-4a85-4fb0-b324-a0a017e27005)

4. Daily Activity Level
```
final_df %>% 
  select(VeryActiveMinutes, 
         FairlyActiveMinutes, 
         LightlyActiveMinutes, 
         SedentaryMinutes) %>% 
  summarise(across(everything(), list(sum))) %>% 
  gather(active_level, minutes) %>% 
  mutate(active_level = factor(active_level, 
                               labels = c('Moderate Activity','Light Activity',
                                          'Sedentary','Heavy Activity'))) %>% 
  hchart('pie', hcaes(x = active_level, y = minutes)) %>% 
  hc_title(text = "Distribution of daily activity level in minutes",
           style = list(fontFamily = "Helvetica", fontSize = "30px"),
           align = "center") %>% 
  hc_tooltip(pointFormat = "<b>Value:</b> {point.y} <br>
                 <b>Percentage</b> {point.percentage:,.2f}%") %>% 
  hc_credits(
    enabled = TRUE, 
    text = "<em>Data Source: FitBit Fitness Tracker Data</em></span>",
    style = list(fontSize = "12px", color = 'black',type = "spline")
)
```
![image](https://github.com/user-attachments/assets/280a3261-fa29-47f4-b83b-e119a32750fe)

5. Sleep Distribution
```
final_df %>% 
  select(TotalMinutesAsleep) %>% 
  drop_na() %>% 
  mutate(sleep_quality = ifelse(TotalMinutesAsleep <= 420, 'Less than 7h',
                                ifelse(TotalMinutesAsleep <= 540, '7h to 9h', 
                                       'More than 9h'))) %>%
  mutate(sleep_quality = factor(sleep_quality, 
                                levels = c('Less than 7h','7h to 9h',
                                           'More than 9h'))) %>% 
  ggplot(aes(x = TotalMinutesAsleep, fill = sleep_quality)) +
  geom_histogram(position = 'dodge', bins = 30) +
  scale_fill_manual(values=c("tan1", "#66CC99", "lightcoral")) +
  theme(legend.position = c(.80, .80),
        legend.title = element_blank(),
        legend.spacing.y = unit(0, "mm"), 
        panel.border = element_rect(colour = "black", fill=NA),
        legend.background = element_blank(),
        legend.box.background = element_rect(colour = "black")) +
  labs(
    title = "Sleep distribution",
    x = "Time slept (minutes)",
    y = "Count",
    caption = 'Data Source: FitBit Fitness Tracker Data'
)
```
![Plot-6](https://github.com/user-attachments/assets/50104c29-f6c3-4c3e-af19-4ff6f6fd2070)

6. Daily Use Pattern

```
daily_use <- sleepDay_merged %>%
  group_by(Id) %>%
  summarize(days_used=sum(n())) %>%
  mutate(user_type= case_when(
    days_used >= 1 & days_used <= 10 ~ "low user",
    days_used >= 11 & days_used <= 20 ~ "moderate user", 
    days_used >= 21 & days_used <= 32 ~ "high user", 
  ))

head(daily_use)
```
Convert it into percentages
```
daily_use_percent <- daily_use %>%
  group_by(user_type) %>%
  summarise(total = n()) %>%
  mutate(totals = sum(total)) %>%
  group_by(user_type) %>%
  summarise(total_percent = total / totals) %>%
  mutate(labels = scales::percent(total_percent))

daily_use_percent$user_type <- factor(daily_use_percent$user_type, levels = c("high user", "moderate user", "low user"))

head(daily_use_percent)
```
Plot the data
```
daily_use_percent %>%
  ggplot(aes(x = "",y = total_percent, fill = user_type)) +
  geom_bar(stat = "identity", width = 1)+
  coord_polar("y", start=0)+
  theme_minimal()+
  theme(axis.title.x= element_blank(),
        axis.title.y = element_blank(),
        panel.border = element_blank(), 
        panel.grid = element_blank(), 
        axis.ticks = element_blank(),
        axis.text.x = element_blank(),
        plot.title = element_text(hjust = 0.5, size=14, face = "bold")) +
  geom_text(aes(label = labels),
            position = position_stack(vjust = 0.5))+
  scale_fill_manual(values = c( "#d62d58","#db7980","#fc9fb7"),
                    labels = c("High user - 21 to 31 days",
                               "Moderate user - 11 to 20 days",
                               "Low user - 1 to 10 days"))+
  labs(title="Daily use of smart device")
```

 ![plot-7](https://github.com/user-attachments/assets/398a1b37-4962-4cfa-b880-3e061a408773)


