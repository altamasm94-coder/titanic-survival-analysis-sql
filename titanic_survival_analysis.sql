drop table if exists train ;
create table if not exists train (
				
	PassengerId	int	primary key 	,
	Survived	boolean	,
	Pclass	int	,	
	Name	varchar(100)	,	
	Sex	varchar(100)	,	
	Age	numeric(10,2)	,	
	SibSp	int	,	
	Parch	int	,	
	Ticket	varchar(100)	,	
	Fare	numeric(10,2)	,	
	Cabin	varchar(100)	,	
	Embarked	varchar(50)		

);

drop table if exists test ;
create table if not exists test (
				
	PassengerId	int	primary key 	,		
	Pclass	int	,	
	Name	varchar(100)	,	
	Sex	varchar(100)	,	
	Age	numeric (10,2)	,	
	SibSp	int	,	
	Parch	int	,	
	Ticket	varchar(100)	,	
	Fare	numeric(10,2)	,	
	Cabin	varchar(100)	,	
	Embarked	varchar(50)		

);

drop table if exists gender_submission ;
create table if not exists gender_submission(
	PassengerId int references test (PassengerId),
	Survived  boolean 

);

-- inserrting data into the tables 

copy train (PassengerId,Survived,Pclass,Name,Sex,Age,SibSp,Parch,Ticket,Fare,Cabin,Embarked)
from 'C:/postgresql/titanic_servival_analysis/train.csv'
csv header ;


copy test (PassengerId,Pclass,Name,Sex,Age,SibSp,Parch,Ticket,Fare,Cabin,Embarked)
from 'C:/postgresql/titanic_servival_analysis/test.csv'
csv header ;


copy gender_submission (PassengerId,Survived)
from 'C:/postgresql/titanic_servival_analysis/gender_submission.csv'
csv header ;

-- -------------------------------------------------------------------
select * from train ; 
select * from test ; 
select * from gender_submission ; 
-- -------------------------------------------------------------------

-- what is the overall survival rate of the pasangers ,

select avg (cast (survived as int )) as survival_rate 
from train;

-- how many passangers survived vs did not survived ,

select sum (case when survived = true then 1 else 0 end ) as paangers_survived , 
	   sum (case when survived = false then 1 else 0 end ) as paangers_did_not_survived
from train ;

-- what is the survival rate by gender ,

select sex , avg (case when survived = true then 1 else 0 end ) 
from train
group by sex ;

-- what is the survival rate by passenger class (pclass) , 

select pclass , avg (case when survived = true then 1 else 0 end ) as suevival_rate 
from train 
group by pclass ;

-- average fair paid by the survivor vs non-survivor ,
select avg (case when survived = true then fare  end ) paid_by_survivors , 
	   avg (case when survived = false then fare end ) paid_by_nonsurvivors 
from train ;

-- -------------------------------------------------------------------
select * from train ; 
select * from test ; 
select * from gender_submission ; 
-- -------------------------------------------------------------------

-- what is the survival rate by embarkation port (Embarked)

select embarked , avg (case when survived = true then 1 else 0 end ) as survival_rate_embarkation_port
from train 
group by Embarked ;

-- what is the average of survivors vs non_survivors 
select 
		avg (case when survived = true  then age end ) as age_of_pasangers_survived ,
		avg (case when survived = false  then age end ) as age_of_pasangers_did_not_survived 
from train ;

-- how many children (age > 18 ) servived  compared to adults 

select count(passengerid) as no_of_children
from train 
where age < 18 and survived = true ;

-- what is the servival rate by familiy size 

select avg (case when survived = true then (sibsp + parch) end ) as the_family_servived ,
		avg (case when survived = false then (sibsp + parch) end ) as the_family_didnot_servived 
from train ;

-- which pasanger class has the heighest average fair 

select pclass ,avg (fare)
from train 
group by pclass
limit 5 ;

-- advanced quarries 


-- -------------------------------------------------------------------
select * from train ; 
select * from test ; 
select * from gender_submission ; 
-- -------------------------------------------------------------------


-- which gender has the heighest servival rate within each pasanger class 

select pclass , sex , 
		avg 
		(case when survived = true then 1 
		else 0 
		end )as gender_with_most_servival_rate 
from train 
group by pclass , sex  ;

-- what is the servival rete of the passenger grouped by both gender and embarkation port 

select sex , embarked,
	avg (case 
	when survived = true then 1
	else 0 
	end ) as pasangers_servived 
from train 
group by sex , embarked ;

-- find the top five passengeers who paid the heighest fare and check if they servived 

select passengerid , fare , survived ,pclass   
from train
order by fare desc
limit 5 ;

-- what is the survival rate for the passenger traveling alone and with family 

select case 
		when (sibsp + parch) = 0 then 'alone'
		else 'with family'
		end as travel_type ,
		avg (case 
		when survived = true then 1 
		else 0 
		end ) as survival_rate 
from train
group by travel_type ;


-- -------------------------------------------------------------------
select * from train ; 
select * from test ; 
select * from gender_submission ; 
-- -------------------------------------------------------------------

-- compare survival rate of customeres with cabin information vs those without 

select case 
		when cabin is not null then 'cabin_information' 
		else 'no_cabin_information'
		end as cabin_information ,

		avg (case 
		when survived = true then 1 
		else 0 
		end ) as survival_rate 

from train
group by cabin_information;

-- using a subquarry find the average of survivors and compare it to the overall average age 

SELECT 
    (SELECT AVG(Age) FROM train WHERE Survived = TRUE) AS avg_age_survivors,
    (SELECT AVG(Age) FROM train) AS avg_age_overall;

-- Survival rate of passengers above median fare

WITH median_cte AS (
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Fare) AS median_fare
    FROM train
)
SELECT AVG(CASE WHEN Survived = TRUE THEN 1 ELSE 0 END) AS survival_rate_above_median
FROM train, median_cte
WHERE Fare > median_cte.median_fare;

-- Window function: rank passengers by fare within class

SELECT PassengerId, Pclass, Fare, Survived,
       RANK() OVER (PARTITION BY Pclass ORDER BY Fare DESC) AS fare_rank
FROM train;

-- Survival rates by age ranges

SELECT 
    CASE 
        WHEN Age BETWEEN 0 AND 10 THEN '0-10'
        WHEN Age BETWEEN 11 AND 20 THEN '11-20'
        WHEN Age BETWEEN 21 AND 40 THEN '21-40'
        ELSE '41+' 
    END AS age_group,
    AVG(CASE WHEN Survived = TRUE THEN 1 ELSE 0 END) AS survival_rate
FROM train
GROUP BY age_group;

-- Join with occupation table (hypothetical)

SELECT d.Occupation,
       AVG(CASE WHEN t.Survived = TRUE THEN 1 ELSE 0 END) AS survival_rate
FROM train t
JOIN passenger_details d ON t.PassengerId = d.PassengerId
GROUP BY d.Occupation;

