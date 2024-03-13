# Generate figures for statistics of the digitization projects

library(ggplot2)
library(DBI)
library(RMariaDB)

source("settings.R")

con <- dbConnect(RMariaDB::MariaDB(), dbname = database, username = user, password = password, host = host, port = port)


steps <- dbGetQuery(con, "SELECT * FROM projects_detail_statistics_steps WHERE stat_type = 'column' and active = 1")


for (i in 1:dim(steps)[1]){
    print(i)
    # To clean
    data <- dbGetQuery(con, paste0("SELECT * FROM projects_detail_statistics WHERE step_id = '", steps[i,]['step_id'], "'"))
    
    if (dim(data)[1] == 0){
        next
    }
    
    data$step_value <- as.numeric(as.character(data$step_value))
    
    filename <- paste0(export_to, "/", steps[i,]['project_id'], "_", steps[i,]['step'],".png")
    p <-
        ggplot(data, aes(y = step_value, x = date)) +
            geom_bar(stat='identity', fill="#009CDE") + 
            scale_x_date(date_labels = "%Y-%m-%d") +
            scale_y_continuous() +
            labs(x = "Date", y = steps[i,]['step_units']) +
            theme(axis.text = element_text(size = 14), axis.title=element_text(size=18,face="bold"))
    png(filename, width = 1600, height = 580)
    print(p)
    dev.off()
    
}


# boxplots

steps <- dbGetQuery(con, "SELECT * FROM projects_detail_statistics_steps WHERE stat_type = 'boxplot' and active = 1")


for (i in 1:dim(steps)[1]){
    print(i)
    # To clean
    data <- dbGetQuery(con, paste0("SELECT date, 
                                   cast(step_value as signed) as step_value, step_id, file_name FROM projects_detail_statistics WHERE step_id = '", steps[i,]['step_id'], "'"))
    
    if (dim(data)[1] == 0){
        next
    }
    
    data$step_value <- as.numeric(as.character(data$step_value))
    
    filename <- paste0(export_to, "/", steps[i,]['project_id'], "_", steps[i,]['step'],".png")
    p <-
        ggplot(data, aes(y = step_value, x = date, group = date)) +
        geom_boxplot(fill="#009CDE") + 
        scale_x_date(date_labels = "%Y-%m-%d") +
        scale_y_continuous() +
        labs(x = "Date", y = steps[i,]['step_units']) +
        theme(axis.text = element_text(size = 14), axis.title=element_text(size=18,face="bold"))
    png(filename, width = 1600, height = 580)
    print(p)
    dev.off()
    
}


dbDisconnect(con)

