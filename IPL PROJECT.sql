select * from ipl_matches;
select * from ipl_ball ;
select * from total_matches_played;

-- EDEN GARDEN TOTAL RUNS
SELECT  SUBSTRING(date,7) AS years ,SUM(total_runs) AS total_runs
FROM deliveries_v03
WHERE venue IN ('Eden Gardens')
GROUP BY years
ORDER BY total_runs DESC;
-- TOTAL RUNS VS VENUE
SELECT venue,SUM(total_runs)AS total_runs
FROM deliveries_v03
GROUP BY venue
ORDER BY total_runs DESC;
-- CREATE TABLE deliveries_v03
CREATE TABLE deliveries_v03 AS
    SELECT
        a.*,
        b.venue,
        SUBSTRING(b.date, 1) AS date
    FROM
        deliveries_v02 a
    LEFT JOIN
        ipl_matches b ON a.id = b.id;
SELECT * FROM deliveries_v03;
DROP TABLE deliveries_v03;


-- COUNT EXTRA RUN
SELECT bowler,SUM(extra_runs) AS extra_runs FROM ipl_ball
WHERE extra_runs!=0 GROUP BY bowler 
ORDER BY extra_runs DESC LIMIT 5;
-- NA COUNT
SELECT COUNT(*) AS total_dismissals FROM ipl_ball
WHERE dismissal_kind!='NA';
-- DOT BALLS VS TEAM
SELECT bowling_team AS team,
COUNT(*) AS dot_count 
FROM deliveries_v02
WHERE ball_result IN ('dot')
GROUP BY team 
ORDER BY dot_count DESC;
-- BOUNDARIES VS TEAM
SELECT batting_team AS team,
COUNT(*) AS boundaries_count 
FROM deliveries_v02
WHERE ball_result IN ('boundaries')
GROUP BY team 
ORDER BY boundaries_count DESC;
-- COUNT BOUNDARIES AND DOT BALLS
SELECT ball_result,COUNT(*)
AS total FROM deliveries_v02 
WHERE ball_result IN ('dot','boundaries')
GROUP BY ball_result;
-- Create table deliveries_v02
CREATE TABLE deliveries_v02 AS
SELECT *,CASE WHEN total_runs>=4 THEN 'boundaries'
WHEN total_runs=0 THEN 'dot' ELSE 'other' END AS 
ball_result FROM ipl_ball;

SELECT * FROM deliveries_v02;
-- COUNT OF ALL CITIES
SELECT COUNT(DISTINCT city) FROM ipl_matches;
-- ALL ROUNDERS
SELECT 
a.batsman AS All_rounder,
a.bat_sr,b.bowling_sr,
(a.bat_sr *1.0-b.bowling_sr) as total_sr
FROM
(SELECT batsman,
ROUND(SUM(total_runs)*1.0/COUNT(ball)*100,2) AS bat_sr
FROM ipl_ball WHERE extras_type NOT IN ('wides')
GROUP BY batsman HAVING COUNT(ball)>500) AS a
INNER JOIN
(SELECT bowler,wicket,
ROUND(balls*1.0/wicket,2)as bowling_sr	   
FROM (SELECT bowler,
COUNT(ball) as balls,
COUNT(CASE WHEN is_wicket=1  AND dismissal_kind 
NOT IN('retired hurt','obstructing the field') THEN 1 END )
AS wicket FROM ipl_ball
GROUP BY bowler HAVING COUNT(ball)>300) AS bowler_sr) AS b 
ON a.batsman=b.bowler
ORDER BY total_sr DESC LIMIT 10;


-- BOWLERS WITH BEST STRIKE RATE
SELECT bowler,ROUND(balls*1.0/wicket,2)as strike_rate	   
FROM (SELECT bowler,
COUNT(ball) as balls,
COUNT(CASE WHEN is_wicket=1  AND dismissal_kind 
NOT IN('retired hurt','obstructing the field') THEN 1 END )
AS wicket FROM ipl_ball
GROUP BY bowler HAVING COUNT(ball)>=500) AS bowler_SR
ORDER BY strike_rate ASC;

--BOWLERS WITH GOOD ECONOMY
SELECT bowler,balls,total_runs,
ROUND(total_runs*1.0/overs,2)as economy	   
FROM (SELECT bowler,
SUM(total_runs) as total_runs,
COUNT(ball) as balls,
COUNT(CASE WHEN ball=6 THEN ball END) as overs
FROM ipl_ball
GROUP BY bowler
HAVING COUNT(ball)>500) AS economy_bowler
ORDER BY economy ASC LIMIT 10;

-- HARD HITTERS
SELECT p.batsman,
p.hard_hitters,
m.total_matches
FROM 
(SELECT batsman,
ROUND(COUNT(CASE WHEN Batsman_runs IN (4,6) 
			THEN Batsman_runs END)*1.0/COUNT(ball)*100,2)
 			AS hard_hitters
FROM ipl_ball
GROUP BY batsman
ORDER BY hard_hitters DESC) AS p 
LEFT JOIN total_matches_played AS m
ON p.batsman=m.player_of_match
WHERE m.total_matches>2
ORDER BY P.hard_hitters DESC LIMIT 10 ;


-- GOOD AVERAGE BATSMANS

-- Creating Table Players Vs Number of matches Played
CREATE TABLE total_matches_played as
SELECT player_of_match,
COUNT(distinct year_c) AS total_matches
FROM ( SELECT player_of_match, SUBSTRING(date, 7) AS year_c FROM ipl_matches) AS years
GROUP BY player_of_match;


-- Findind Batsman with Good Average 
SELECT p.batsman,
p.total_runs,
p.total_runs/p.wicket as Average_batsman
FROM
(SELECT batsman,SUM(total_runs) as total_runs,COUNT(CASE WHEN is_wicket>0 THEN 1 END) AS wicket 
FROM ipl_ball 
WHERE  extras_type NOT IN ('wides') 
GROUP BY batsman ) as p LEFT JOIN  total_matches_played as m	 
ON p.batsman=m.player_of_match
WHERE p.wicket>0 and m.total_matches>2
ORDER BY Average_batsman DESC LIMIT 10;

-- AGRESSIVE BATSMANS	
SELECT batsman,
(SUM(total_runs)*1.0/COUNT(ball))*100 as strike_rate
FROM ipl_ball
WHERE  extras_type NOT IN ('wides')
GROUP BY batsman
HAVING count(ball)>500
ORDER BY strike_rate DESC LIMIT 10;














