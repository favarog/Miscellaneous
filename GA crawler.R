
#------------------------- Google Analytics Crawler 

library(rga); rga.open(instance = "ga")

ga_start_date <- "2015-11-01"
ga_end_date <- Sys.Date()
ga_id <- "106875055" #instacarro all website data
ga_kpis <- ga$getData(ga_id, batch = T, start.date = ga_start_date, end.date = ga_end_date, 
                      metrics = "ga:sessions, ga:goal3completions, ga:adCost, ga:goal17completions, ga:goal19completions, ga:goal13completions",
                      dimensions = "ga:year, ga:month")
