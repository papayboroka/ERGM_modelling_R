library(ergm)
library(sna) 
library('readr')
library('igraph')
library('intergraph')
library('network')



setwd("C:/Git")
attributes <-read_delim("test_attributes_ergm.csv",col_names=TRUE, delim='\t')
networks <-read_delim("test_data_ergm.csv",col_names=TRUE, delim='\t')

#extracting the list of networks
network_list=unique(networks$network_id)

# extracting the list of organizations
organization_list = unique(attributes$group)

# Add here any number of explanatory networks by their name
#explanatory networks
explanatory_networks <- c('despised','would_reduce_salary')

# Add here any number of explanatory attributes with their effect
#explanatory attributes wih their ERGM effect
explanatory_attributes <- list(c(attr='gender', effect='nodefactor'),
                               c(attr='opinion2', effect='nodecov'))

#selecting dependent network, adding vertex attributes to the dependent network
attributes <- attributes[order(attributes$respondent),] 
every_employee <- attributes$respondent
dependent_network <- networks[networks$network_id=='friends',]
dependent_network <- unique(dependent_network[3:4])
dependent_network <- asNetwork(graph_from_data_frame(dependent_network, vertices=every_employee))
for (n in colnames(attributes)){
    variable <- attributes[[n]]
    network::set.vertex.attribute(dependent_network, n, variable)
}


                               



#result dataframe
result= data.frame()


#iterating through the list of workgroups
for (i in organization_list) {
  print(i)
# selecting the attributes for companies
  attributescompany <- attributes[attributes$group==i,]
  group_employees <- attributescompany$respondent
# selecting the network edgelists for companies
  networks_company <- networks[networks$group==i,]
  networks_company <- networks_company[3:5]
  explanatory_network_list <- c()
  
  # dependent network for company
  group_membership <- network::get.vertex.attribute(dependent_network, "group")
  group_vertex_ids <- which(group_membership == i)
  dependent_network_company <- get.inducedSubgraph(dependent_network, group_vertex_ids)
  
#Writing  the previous selected explanatory networks into a vector
  counter=0
  for (y in explanatory_networks) {
    counter=counter+1
    for (z in network_list) {
      if (y==z){
        current_network <- networks_company[
          networks_company$network_id == y,
          ]
        
        e_network <- graph_from_data_frame(current_network, vertices=group_employees)
        e_network <- asNetwork(e_network)
        assign(paste(y,i,'network',sep=''),e_network)
        explanatory_network_list[counter] <- paste(y,i,'network',sep='')
      }
    }
  }
  explanatory_network_string = ''
#generating a string with all the explanatory networks
  for (element in explanatory_network_list) {
    explanatory_network_string = paste(explanatory_network_string,element, sep =') + edgecov(')
  }
  explanatory_network_string = substr(explanatory_network_string, 4, nchar(explanatory_network_string))
# writing the attribute effects into the string based on explanatory_attributes variable
  explanatory_attributes_string=''
  for (w in explanatory_attributes) {
    e_attributes_string = paste( '+',w[['effect']], '("', w[['attr']],'")', sep='')
    explanatory_attributes_string = paste(explanatory_attributes_string,e_attributes_string,sep='')
  }
  
#writing the formula  as a string  
  formula = ''
  formula = paste('dependent_network_company ~ density + istar(1) + ostar(1) +', explanatory_network_string, ')', explanatory_attributes_string, sep='')

  #running ERGM only if dependent network is not empty
  if(network.edgecount(dependent_network_company) > 0){
    m = tryCatch(ergm(as.formula(formula)), error=function(e) e)
    if(!is.na(m)){
      
      # Get ERGM coefficient output
      model_summary <- summary.ergm(m)
      output <- model_summary$coefs
      output$prob <- exp(output$Estimate)/(1+exp(output$Estimate))
      colnames(output) <- paste(i,'_',colnames(output),sep='')
      row.names(output) <- gsub(i, '', row.names(output))
      output$var_names <- row.names(output)
      
      #putting the results in one table
        print("Writing to result...")
        if (nrow(result)==0){
          result=output
        } else {
          result = merge(result, output, by="var_names",all.x=TRUE)
        }
    }
    
  }
}