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
    #data <- dbGetQuery(con, paste0("SELECT * FROM projects_detail_statistics WHERE step_id = '", steps[i,]['step_id'], "'"))
    data <- dbGetQuery(con, paste0("SELECT date, 
                                   avg(cast(step_value as signed)) as step_value, step_id FROM projects_detail_statistics WHERE step_id = '", steps[i,]['step_id'], "' GROUP BY date, step_id"))
    
    if (dim(data)[1] == 0){
        next
    }
    
    data$step_value <- as.numeric(as.character(data$step_value))

    
    # Get time estimate for x scale
    
    min_date <- min(data$date)
    max_date <- max(data$date)
    
    if ((max_date - min_date) > 42){
        date_by <- 14
    }else if ((max_date - min_date) > 20 && (max_date - min_date) <= 42){
        date_by <- 7
    }else{
        date_by <- 2
    }
    
    print(steps[i,]['step'])
    if (steps[i,]['step'] == 'archive_records'){
        date_breaks <- (date_breaks = "1 month")
        date_lab <- "%Y-%m"
    }else{
        date_breaks <- seq(min_date, max_date, by = date_by)
        date_lab <- "%Y-%m-%d"
    }
    
    filename <- paste0(export_to, "/", steps[i,]['project_id'], "_", steps[i,]['step'],".png")
    p <-
        ggplot(data, aes(y = step_value, x = date)) +
        geom_bar(stat='identity', fill="#009CDE") +
        scale_x_date(date_labels = date_lab, breaks = date_breaks) +
        scale_y_continuous() +
        labs(x = "Date", y = steps[i,]['step_units']) +
        theme(axis.text = element_text(size = 14), axis.title=element_text(size=18,face="bold"))
    png(filename, width = 1600, height = 580)
    print(p)
    dev.off()
    

    
    # filename <- paste0(export_to, "/", steps[i,]['project_id'], "_", steps[i,]['step'],".png")
    # p <-
    # ggplot(data, aes(y = step_value, x = date)) +
    #     geom_point() +
    #     geom_smooth(span = 0.5) +
    #     scale_x_date(date_labels = "%Y-%m-%d", breaks = seq(min_date, max_date, by = date_by)) +
    #     scale_y_continuous() +
    #     labs(x = "Date", y = steps[i,]['step_units']) +
    #     theme(axis.text = element_text(size = 14), axis.title=element_text(size=18,face="bold"))
    # png(filename, width = 1600, height = 580)
    # print(p)
    # dev.off()
    
    
    
}


# boxplots

steps <- dbGetQuery(con, "SELECT * FROM projects_detail_statistics_steps WHERE stat_type = 'boxplot' and active = 1")


for (i in 1:dim(steps)[1]){
    print(i)
    # To clean
    data <- dbGetQuery(con, paste0("SELECT date, 
                                   avg(cast(step_value as signed)) as step_value, step_id FROM projects_detail_statistics WHERE step_id = '", steps[i,]['step_id'], "' GROUP BY date, step_id"))
    
    if (dim(data)[1] == 0){
        next
    }
    
    data$step_value <- as.numeric(as.character(data$step_value))
    
    # filename <- paste0(export_to, "/", steps[i,]['project_id'], "_", steps[i,]['step'],".png")
    # p <-
    #     ggplot(data, aes(y = step_value, x = date, group = date)) +
    #     geom_boxplot(fill="#009CDE") + 
    #     scale_x_date(date_labels = "%Y-%m-%d") +
    #     scale_y_continuous() +
    #     labs(x = "Date", y = steps[i,]['step_units']) +
    #     theme(axis.text = element_text(size = 14), axis.title=element_text(size=18,face="bold"))
    # png(filename, width = 1600, height = 580)
    # print(p)
    # dev.off()
    # 
    
    
    # 
    # min_date <- min(data$date)
    # max_date <- max(data$date)
    # 
    # if ((max_date - min_date) > 30){
    #     date_by <- 14
    # }else{
    #     date_by <- 7
    # }
    # 
    # filename <- paste0(export_to, "/", steps[i,]['project_id'], "_", steps[i,]['step'],".png")
    # p <-
    #     ggplot(data, aes(y = step_value, x = date)) +
    #     geom_point() +
    #     geom_smooth(span = 0.5) +
    #     scale_x_date(date_labels = "%Y-%m-%d", breaks = seq(min_date, max_date, by = date_by)) +
    #     scale_y_continuous() +
    #     labs(x = "Date", y = steps[i,]['step_units']) +
    #     theme(axis.text = element_text(size = 14), axis.title=element_text(size=18,face="bold"))
    # png(filename, width = 1600, height = 580)
    # print(p)
    # dev.off()
    
    min_date <- min(data$date)
    max_date <- max(data$date)
    
    if ((max_date - min_date) > 42){
        date_by <- 14
    }else if ((max_date - min_date) > 20 && (max_date - min_date) <= 42){
        date_by <- 7
    }else{
        date_by <- 2
    }
    
    
    filename <- paste0(export_to, "/", steps[i,]['project_id'], "_", steps[i,]['step'],".png")
    p <-
        ggplot(data, aes(y = step_value, x = date)) +
        geom_bar(stat='identity', fill="#009CDE") +
        scale_x_date(date_labels = "%Y-%m-%d", breaks = seq(min_date, max_date, by = date_by)) +
        scale_y_continuous() +
        labs(x = "Date", y = steps[i,]['step_units']) +
        theme(axis.text = element_text(size = 14), axis.title=element_text(size=18,face="bold"))
    png(filename, width = 1600, height = 580)
    print(p)
    dev.off()
    
}







# area

steps <- dbGetQuery(con, "SELECT * FROM projects_detail_statistics_steps WHERE stat_type = 'area' and active = 1")


for (i in 1:dim(steps)[1]){
    print(i)
    # To clean
    data <- dbGetQuery(con, paste0("SELECT date, 
                                   step_value, step_id FROM projects_detail_statistics WHERE step_id = '", steps[i,]['step_id'], "'"))
    
    if (dim(data)[1] == 0){
        next
    }
    
    data$step_value <- as.numeric(as.character(data$step_value))
    
    min_date <- min(data$date)
    max_date <- max(data$date)
    
    if ((max_date - min_date) > 42){
        date_by <- 14
    }else if ((max_date - min_date) > 20 && (max_date - min_date) <= 42){
        date_by <- 7
    }else{
        date_by <- 2
    }
    
    # Set to of area curve to 5% over max
    y_limit <- max(data$step_value) + (max(data$step_value) * 0.05)
    
    filename <- paste0(export_to, "/", steps[i,]['project_id'], "_", steps[i,]['step'],".png")
    
    
    p <- ggplot(data, aes(y=step_value, x=date)) + 
        geom_area(stat='identity', fill="#009CDE") +
        scale_x_date(date_labels = "%Y-%m-%d", breaks = seq(min_date, max_date, by = date_by)) +
        scale_y_continuous() +
        labs(x = "Date", y = steps[i,]['step_units']) +
        theme(axis.text = element_text(size = 14), axis.title=element_text(size=18,face="bold"))
    
    png(filename, width = 1600, height = 580)
    print(p)
    dev.off()
    
}





# timeline
# 
# df <- dbGetQuery(con, "SELECT s.project_id, s.step_info, e.date, e.step_value FROM projects_detail_statistics_steps s left join projects_detail_statistics e on (s.step_id = e.step_id) WHERE s.stat_type = 'timeline' and s.active = 1 ORDER BY e.date")
# 
# 
# min_date <- min(df$date)
# max_date <- max(df$date)
# 
# if ((max_date - min_date) > 42){
#     date_by <- 14
# }else if ((max_date - min_date) > 20 && (max_date - min_date) <= 42){
#     date_by <- 7
# }else{
#     date_by <- 2
# }
# 
# filename <- paste0(export_to, "/", '1ab9e0c1-0e34-4e4f-a512-8a6801fefde7', "_", 'timeline',".png")
# 
# p <- ggplot(df,aes(x=date,y=0, label=step_info)) +
#     geom_hline(yintercept=0, 
#                 color = "black", size=0.3) +
#     geom_segment(data=df, aes(y=0.1,yend=0,xend=date), color='black', size=0.2) +
#     geom_point(aes(y=0), size=3) +theme(axis.line.y=element_blank(),
#                                         axis.text.y=element_blank(),
#                                         axis.title.x=element_blank(),
#                                         axis.title.y=element_blank(),
#                                         axis.ticks.y=element_blank())+
#     geom_text(aes(colour = factor(step_info), y=0.11, label=step_info), size=8, angle=45, show.legend = FALSE)+
#     scale_colour_discrete(l = 40) +
#     scale_y_continuous(limits = c(0, 0.15))
#     
# 
# png(filename, width = 1600, height = 380)
# print(p)
# dev.off()




dbDisconnect(con)

