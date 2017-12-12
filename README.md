# ERGM_modelling_R

The code runs ERGM using Statnet. ERGM is executed on multiple groups, collecting their results in one table. Before executing the model, you can add any number of explanatory networks and explanatory attributes for all the groups.


## Expected data structures

You can also check the test datasets
### Networks

Networks are expected as edge lists. For all the companies (schools or other units), all the work groups (school classes or any type of groups), for all the directed networks within one table.
Calculations are usually done by workgroups. 

Dataframe should look like the following:

Read csv by the following command: `file <- read.csv(...)`

```
company	group	respondent	nominated_person	network_id
A   	  Ac  	A01	        A14	              friend
A   	  Ac	  A02	        A08	              friend
A   	  Ac	  A01	        A14	              admired
A   	  Ad	  A25	        A14	              friend
...
B   	  Bc  	Bc01	        Bc14	          friend
B   	  Bc	  Bc02	        Bc08	          friend
B   	  Bc	  Bc01	        Bc14	          admired
B   	  Bd	  Bd12	        Bd22	          friend
```
### Attributes
Dataframe with the following columns:
```
respondent  group org
```
and any other attribute
