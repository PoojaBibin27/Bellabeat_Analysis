# Load libraries
library(tidyverse)
library(kableExtra)  
library(scales)   
library(highcharter) 
library(RColorBrewer)  
library(lubridate)

# To view the dataset
view(FInal_df)
head(FInal_df)

# Summary of the dataset
summary(FInal_df)
  
#remove null values
final_df <- FInal_df %>%
  distinct() %>%
  drop_na()

#Basic Insights
final_df %>%  
  select(TotalSteps,
         TotalDistance,
         SedentaryMinutes, Calories) %>%
  summary()

#Steps vs Calories

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

#Correltion Coefficient
cor.test(final_df$TotalSteps, final_df$Calories, method = 'pearson', conf.level = 0.95)

# Steps per Weekday
weekday_steps <- final_df %>%
  mutate(weekday = weekdays(Date))
weekday_steps$weekday <-ordered(weekday_steps$weekday, levels=c("Monday", "Tuesday", "Wednesday", "Thursday",
                                                                "Friday", "Saturday", "Sunday"))
weekday_steps <-weekday_steps %>%
  group_by(weekday) %>%
  summarize (daily_steps = mean(TotalSteps))

head(weekday_steps)

ggplot(weekday_steps, aes(weekday, daily_steps)) +
  geom_col(fill = "#d62d58") +
  geom_hline(yintercept = 7500) +
  labs(title = "Daily steps per weekday", x= "", y = "") +
  theme(axis.text.x = element_text(angle = 45,vjust = 0.5, hjust = 1))

#Inensity of Activity
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

#Daily Activity Level

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

# Sleep Distribution

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

#Smart Device Usage
#create a new df to track daily usage
daily_use <- sleepDay_merged %>%
  group_by(Id) %>%
  summarize(days_used=sum(n())) %>%
  mutate(user_type= case_when(
    days_used >= 1 & days_used <= 10 ~ "low user",
    days_used >= 11 & days_used <= 20 ~ "moderate user", 
    days_used >= 21 & days_used <= 32 ~ "high user", 
  ))

head(daily_use)

#create percentages of daily usage

daily_use_percent <- daily_use %>%
  group_by(user_type) %>%
  summarise(total = n()) %>%
  mutate(totals = sum(total)) %>%
  group_by(user_type) %>%
  summarise(total_percent = total / totals) %>%
  mutate(labels = scales::percent(total_percent))

daily_use_percent$user_type <- factor(daily_use_percent$user_type, levels = c("high user", "moderate user", "low user"))

head(daily_use_percent)

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

