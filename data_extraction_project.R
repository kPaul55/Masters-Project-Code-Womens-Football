#Get necessary libraries
library(devtools)
devtools::install_github("statsbomb/StatsBombR")
library(StatsBombR)
library(tidyverse)
library(dplyr)
library(tidyr)

#Obtain the competition and match data
Comp <- FreeCompetitions()
matches <- FreeMatches(Comp)
#Filter the data to only have the data for the past two womens world cups
matches <- matches %>% filter(competition.competition_name=="Women's World Cup")
data360 <- free_allevents_360(MatchesDF = matches, Parallel = T) #collect the 360 data

#Pull the event data and clean it using the allclean function
events <- free_allevents(MatchesDF = matches, Parallel = T)
events <- allclean(events)
events <- get.opposingteam(events)

#Join the 360 dataframe to the event dataframe
data360 = data360 %>% rename(id = event_uuid)
events = events %>% left_join(data360, by = c("id" = "id"))
events = events %>% rename(match_id = match_id.x) %>% select(-match_id.y)

#Create a new dataframe that filters to obtain only the pass event data
full_df = events %>%
  group_by(team.name) %>%
  filter(type.name=="Pass") %>%
  select(id, match_id, team.name, OpposingTeam, player.name, position.name, play_pattern.name,
         type.name, minute, second, duration, location.x, location.y, under_pressure,
         pass.end_location.x, pass.end_location.y, pass.length, pass.angle, pass.recipient.name, pass.height.name, pass.body_part.name,
         pass.type.name, pass.cross, pass.switch, pass.through_ball, pass.goal_assist,pass.shot_assist, pass.outcome.name,
         pass.technique.name, freeze_frame)
#colnames(full_df)

#Unnest the 360 data
full_df = full_df %>% unnest(freeze_frame) %>%
  mutate(ff_location.x = (map(location, 1)), ff_location.y = (map(location, 2))) %>%
  select(-location) %>%
  mutate(ff_location.x = as.numeric(ifelse(ff_location.x == "NULL", NA, ff_location.x)), ff_location.y = as.numeric(ifelse(ff_location.y == "NULL", NA, ff_location.y)))

#Only keep the 360 player data points that aren't the player passing the ball
full_df <- full_df %>%
  filter(actor != "TRUE")

#Rename the location data columns
full_df <- full_df %>%
  rename(
    fflocation_x = ff_location.x,
    fflocation_y = ff_location.y
  )


#Separate columns to keep
columns_to_keep <- full_df %>%
  distinct(id, .keep_all = TRUE) %>% 
  select(id, match_id, team.name, OpposingTeam, player.name, position.name, play_pattern.name,
         type.name, minute, second, duration, location.x, location.y, under_pressure,
         pass.end_location.x, pass.end_location.y, pass.length, pass.angle, pass.recipient.name, pass.height.name, pass.body_part.name,
         pass.type.name, pass.cross, pass.switch, pass.through_ball, pass.goal_assist,pass.shot_assist, pass.outcome.name,
         pass.technique.name)

#Change the format of the 360 data. Each pass has a column for every players location 
df_long <- full_df %>%
  group_by(id) %>%
  select(matches("fflocation_|teammate")) %>%  
  mutate(row_id = row_number()) %>%  #pivot longer to obtain in column format
  pivot_longer( 
    cols = matches("fflocation_|teammate"),
    names_to = "difference_type",
    values_to = "value"
  ) %>%
  mutate(unique_col_name = paste(difference_type, row_id, sep = "_")) %>%
  select(unique_col_name, value) %>%
  pivot_wider(
    names_from = unique_col_name,
    values_from = value
  )

#combine the dataframe that was transformed with the columns to keep
df_combined <- columns_to_keep %>%
  left_join(df_long, by = "id")

#rename the dataframe and mutate it such that the numeric columns only have 1 decimal place
womens_pass_data <- df_combined %>%
  mutate(across(where(is.numeric), round, 1))

#install library that read and writes data to files
library(openxlsx)
#write the df to a excel file to then use in python to clean and prep for modelling
write.xlsx(womens_pass_data, 'C:\\Users\\kpaul\\Documents\\Univeristy of Glasgow - MSc\\Semester 4 - Fall 2024\\Final Year Project\\womens_pass_data_new.xlsx')














