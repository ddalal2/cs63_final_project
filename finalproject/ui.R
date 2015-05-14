library(shiny)
library(shinydashboard)
library(rCharts)

dashboardPage(
  dashboardHeader(
    title = " CS63 Final Project"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Researcher Productivity", tabName = "R", icon = icon("graduation-cap")),
      menuItem("Journal Productivity", tabName = "J", icon = icon("book")),
      menuItem("About", tabName = "A", icon = icon("user"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "R",
              h2("Researcher Productivity"),
              p("Click any panel to continue"),
              tabsetPanel(
                br(),
                br(),
                tabPanel("Publications",
                         box(showOutput("q1", "highcharts"), width = 8),
                         box(h2("About"), width = 4,
                             p("Guiding Question: Who has published the most articles?"),
                             p("Longevity calculations based on AMINER rising star equation:"),
                             img(src = "long.jpg", width = 300),
                             p("Where we take authors first and last publication and subtract publications years."),
                             h3("Cypher Query"),
                             p("MATCH (a:Author) -[w:WROTE]-> (p:Paper)"),
                             p("RETURN a.name AS Name, COUNT(p) AS Count, MAX(w.year) - MIN(w.year) 
                           AS Long_Score"),
                             p("ORDER BY COUNT(p) DESC LIMIT 26"))
                ),
                tabPanel("Rising Stars",
                         fluidRow(box(showOutput("q2", "highcharts"), width = 8)),
                         fluidRow( box(h2("About"), width = 12,
                                       p("Guiding Question: Who are the rising stars in the field?"),
                                       p("Looking researchers whose longevity scores are less than 5. That is new researchers whose first publication was in the last 5 years and thier overall research productivity."),
                                       p("Longevity calculations based on AMINER rising star equation:"),
                                       img(src = "long.jpg", width = 450),
                                       p("Where we take authors first and last publication and subtract publications years."),
                                       h3("Cypher Query"),
                                       p("MATCH (a:Author) -[w:WROTE]-> (p:Paper)"),
                                       p("RETURN a.name AS Name, COUNT(p) AS Count, MAX(w.year) - MIN(w.year) 
                                         AS Long_Score"),
                                       p("ORDER BY COUNT(p) DESC LIMIT 26")))
                         ),
                tabPanel("Socialbility",
                         box(showOutput("q3", "highcharts"), width = 7),
                         box(h2("About"), width = 5,
                             p("Guiding Question: Which author has the most co-authors?"),
                             p("Socialbility calculations based on AMINER rising star equation:"),
                             img(src = "social.jpg", width = 300),
                             p("Where the score is the sum all co-authors per author."),
                             h3("Cypher Query"),
                             p("MATCH (a:Author) -[WROTE]-> (p:Paper)<-[WRITTEN_BY]- (o:Author)"),
                             p("RETURN a.name as Name, 1 + COUNT(DISTINCT(o)) as Social_Score"),
                             p("ORDER BY Social_Score DESC LIMIT 25"))
                         )
              )
              ),
      tabItem(tabName = "J",
              h2("Journal Productivity"),
              fluidRow(
                box(showOutput("q4", "highcharts"), width = 6),
                box(h2("About"),
                    p("Guiding question: Which Journal have on average the most cited papers?"),
                    h3("Cypher Query"),
                    p("MATCH (j:Journal) -[PUBLISHED_PAPER]->(p:Paper)<-[c:CITED_BY] - (o:Paper)"),
                    p("RETURN j.name as Journal, p.title as Paper, COUNT(o) as Citations"))
              )),
      tabItem(tabName = "A",
              h3("Dhairya Dalal"),
              h4("ALM, Software Engineering (candidate)"),
              h4("Harvard University Extension School"),
              p("This is a final project for Harvard's CS63 Big Data Analytics class."),
              p("If you have any questions email me at dhairya[dot]b[dot]dalal[@]gmail.com"),
              p("Source code can be found on github:"),
              a("Github", href= "https://github.com/ddalal2/cs63_final_project"))
    )
  )
)