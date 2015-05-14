library(dplyr)
library(RNeo4j)
library(ggplot2)
library(rCharts)
###################### [Load Graph] ########################
graph = startGraph("http://localhost:7474/db/data/", 
                   username = 'neo4j',
                   password =  'password')
###################### [/Load Graph] ########################

###################### [Analysis] ########################
#1. Question: Who has published the most articles
#a. Get Data with Cypher query
q1 = "MATCH (a:Author) -[w:WROTE]-> (p:Paper)
      RETURN a.name AS Name, COUNT(p) AS Count, MAX(w.year) - MIN(w.year) AS Long_Score
      ORDER BY COUNT(p) DESC LIMIT 26"
q1_results = cypher(graph, q1)[-1,] #Q1 Data

#b. Visualize Results
q1 <- rCharts:::Highcharts$new()
q1$chart(zoomType = "xy", type = 'bar')
q1$xAxis(categories = q1_results$Name, title = list(text="Authors"))
q1$title(text="Most Published Authors")
q1$series(data = q1_results$Long_Score, name = "Longevity Score (years)", legendIndex = 2 )
q1$series(data = q1_results$Count, name = "Publication Count", legendIndex = 1)
q1$show()

#Q2. Who are the Rising Stars in the Field? 
q2 = "MATCH (a:Author) -[w:WROTE]-> (p:Paper)
      RETURN a.name AS Name, COUNT(p) AS Count, MAX(w.year) - MIN(w.year) AS Long_Score
      ORDER BY COUNT(p) DESC"
      
q2_results = cypher(graph, q2)[-1,] #Q2 Data
# Filter results in dplyr for long_score <= 5 and order in desc with most citation counts
q2_results <- (q2_results %>% filter(Long_Score <= 5) %>% arrange(desc(Count)))[1:25,] #Data

#b. Visualize Results
q2 <- rCharts:::Highcharts$new()
q2$chart(zoomType = "xy", type = 'bar')
q2$xAxis(categories = q2_results$Name, title = list(text="Authors"))
q2$title(text="Rising Stars Authors")
q2$series(data = q2_results$Long_Score, name = "Longevity Score (years)", legendIndex = 2 )
q2$series(data = q2_results$Count, name = "Publication Count", legendIndex = 1)
q2$show()

#Q3. Which Author was the most socialable? 
q3 <- "MATCH (a:Author) -[WROTE]-> (p:Paper)<-[WRITTEN_BY]- (o:Author)
       RETURN a.name as Name, 1 + COUNT(DISTINCT(o)) as Social_Score
       ORDER BY Social_Score DESC
       LIMIT 25"
q3_results = cypher(graph, q3) #Q3 Data

#b. Visualize Results
q3 <- rCharts:::Highcharts$new()
q3$chart(zoomType = "xy", type = 'bar')
q3$xAxis(categories = q3_results$Name, title = list(text="Authors"))
q3$yAxis(title = list(text = "Score"))
q3$title(text="Most Socialble Authors")
q3$series(data = q3_results$Social_Score, name = "Socialbility Score")
q3$show()

#Q4: Which Journal have on average the most cited papers?
q4 <- "MATCH (j:Journal) -[PUBLISHED_PAPER]->(p:Paper)<-[c:CITED_BY] - (o:Paper)
       RETURN j.name as Journal, p.title as Paper, COUNT(o) as Citations"
q4_results = cypher(graph, q4) #Q4 Data
q4_results <- q4_results %>% group_by(Journal) %>% 
              summarise(paper_count = n(), 
                        c_count = sum(Citations), 
                        avg_cits = round(c_count / paper_count,2)) %>%
              filter(paper_count > 70) %>%
              arrange(desc(avg_cits))
q4_results <- q4_results[1:10,]

#b. Visualize Results
q4 <- rCharts:::Highcharts$new()
q4$chart(zoomType = "xy", type = 'bar')
q4$xAxis(categories = q4_results$Journal, title = list(text="Authors"))
q4$yAxis(title = list(text = "Avg. Citations per Paper"))
q4$title(text="Top Journals Based on Avg Citations")
q4$series(data = q4_results$avg_cits, name = "Avg. Citations")
q4$show()
###################### [/Analysis] ########################

# Save data to RData object
save(q1_results, q2_results, q3_results, q4_results, file = "finalproject/data.RData")