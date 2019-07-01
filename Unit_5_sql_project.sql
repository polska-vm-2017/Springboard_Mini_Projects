/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */


SELECT * FROM `Facilities` 
WHERE membercost = 0

/*
facid	name	membercost	guestcost	initialoutlay	monthlymaintenance	
2	Badminton Court	0.0	15.5	4000	50
3	Table Tennis	0.0	5.0	320	10
7	Snooker Table	0.0	5.0	450	15
8	Pool Table	0.0	5.0	400	15
*/

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT( * ) 
FROM  `Facilities` 
WHERE membercost =0

/* 4 */


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM  `Facilities` 
WHERE membercost < ( 0.2 * monthlymaintenance ) 

/*
facid	name	membercost	monthlymaintenance	
0	Tennis Court 1	5.0	200
1	Tennis Court 2	5.0	200
2	Badminton Court	0.0	50
3	Table Tennis	0.0	10
4	Massage Room 1	9.9	3000
5	Massage Room 2	9.9	3000
6	Squash Court	3.5	80
7	Snooker Table	0.0	15
8	Pool Table	0.0	15
*/

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
FROM  `Facilities` 
WHERE facid IN ( 1, 5 ) 

/*
facid	name	membercost	guestcost	initialoutlay	monthlymaintenance	
1	Tennis Court 2	5.0	25.0	8000	200
5	Massage Room 2	9.9	80.0	4000	3000
*/

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance >100
THEN  'expensive'
ELSE  'cheap'
END AS exp_or_cheap
FROM  `Facilities`

/*
name	monthlymaintenance	exp_or_cheap	
Tennis Court 1	200	expensive
Tennis Court 2	200	expensive
Badminton Court	50	cheap
Table Tennis	10	cheap
Massage Room 1	3000	expensive
Massage Room 2	3000	expensive
Squash Court	80	cheap
Snooker Table	15	cheap
Pool Table	15	cheap 
*/

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM  `Members` 
WHERE joindate = ( 
SELECT MAX( joindate ) 
FROM  `Members` )

/*
firstname	surname	
Darren	Smith
*/

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT crts.facname, CONCAT(mems.firstname, " ", mems.surname) As full_name
FROM `Members` mems
JOIN
(SELECT DISTINCT facil.name AS facname, bks.memid AS memid
FROM  `Bookings` bks
JOIN
(SELECT facid, name
FROM `Facilities`) facil
ON bks.facid = facil.facid
WHERE facil.name LIKE  'Tennis Court%') crts
ON mems.memid = crts.memid
ORDER BY full_name

/*
facname	full_name	
Tennis Court 2	Anne Baker
Tennis Court 1	Anne Baker
Tennis Court 2	Burton Tracy
Tennis Court 1	Burton Tracy
Tennis Court 1	Charles Owen
Tennis Court 2	Charles Owen
Tennis Court 2	Darren Smith
Tennis Court 1	David Farrell
Tennis Court 2	David Farrell
Tennis Court 2	David Jones
Tennis Court 1	David Jones
Tennis Court 1	David Pinker
Tennis Court 1	Douglas Jones
Tennis Court 1	Erica Crumpet
Tennis Court 1	Florence Bader
Tennis Court 2	Florence Bader
Tennis Court 2	Gerald Butters
Tennis Court 1	Gerald Butters
Tennis Court 2	GUEST GUEST
Tennis Court 1	GUEST GUEST
Tennis Court 2	Henrietta Rumney
Tennis Court 2	Jack Smith
Tennis Court 1	Jack Smith
Tennis Court 1	Janice Joplette
Tennis Court 2	Janice Joplette
Tennis Court 1	Jemima Farrell
Tennis Court 2	Jemima Farrell
Tennis Court 1	Joan Coplin
Tennis Court 2	John Hunt
Tennis Court 1	John Hunt
*/


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */



SELECT bksfac.fac_name, CONCAT(mems.firstname, " ", mems.surname) As full_name, bksfac.slot_cost
FROM `Members` mems
JOIN
(SELECT bk.memid, bk.facid, bk.slots, bk.starttime, facil.fac_name, facil.guestcost, facil.membercost, 
CASE WHEN bk.memid = 0
	THEN bk.slots * facil.guestcost
	ELSE bk.slots * facil.membercost
	END AS slot_cost
FROM `Bookings`bk
JOIN
(SELECT facid, name AS fac_name, guestcost, membercost
FROM `Facilities`) facil
ON bk.facid = facil.facid
WHERE bk.starttime >= '2012-09-14'
AND bk.starttime <= '2012-09-15') bksfac
ON mems.memid = bksfac.memid
WHERE bksfac.slot_cost > 30
ORDER BY bksfac.slot_cost DESC

/*
fac_name	full_name	slot_cost	
Massage Room 2	GUEST GUEST	320.0
Massage Room 1	GUEST GUEST	160.0
Massage Room 1	GUEST GUEST	160.0
Massage Room 1	GUEST GUEST	160.0
Tennis Court 2	GUEST GUEST	150.0
Tennis Court 2	GUEST GUEST	75.0
Tennis Court 1	GUEST GUEST	75.0
Tennis Court 1	GUEST GUEST	75.0
Squash Court	GUEST GUEST	70.0
Massage Room 1	Jemima Farrell	39.6
Squash Court	GUEST GUEST	35.0
Squash Court	GUEST GUEST	35.0
*/

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT *
FROM
(SELECT fac.name AS fac_name, CONCAT(mem.firstname, " ", mem.surname) As full_name,
CASE WHEN bkg.memid = 0
	THEN bkg.slots * fac.guestcost
	ELSE bkg.slots * fac.membercost
	END AS slot_cost
FROM `Facilities` fac, `Bookings` bkg, `Members` mem
WHERE fac.facid = bkg.facid
AND mem.memid = bkg.memid
AND bkg.starttime >= '2012-09-14'
AND bkg.starttime <= '2012-09-15'
ORDER BY slot_cost DESC) a
WHERE a.slot_cost > 30

/*
fac_name	full_name	slot_cost	
Massage Room 2	GUEST GUEST	320.0
Massage Room 1	GUEST GUEST	160.0
Massage Room 1	GUEST GUEST	160.0
Massage Room 1	GUEST GUEST	160.0
Tennis Court 2	GUEST GUEST	150.0
Tennis Court 2	GUEST GUEST	75.0
Tennis Court 1	GUEST GUEST	75.0
Tennis Court 1	GUEST GUEST	75.0
Squash Court	GUEST GUEST	70.0
Massage Room 1	Jemima Farrell	39.6
Squash Court	GUEST GUEST	35.0
Squash Court	GUEST GUEST	35.0
*/

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT b.fac_name, b.Total_Revenue
FROM
(SELECT a.fac_name, SUM(a.slot_cost) AS Total_Revenue
FROM
(SELECT fac.name AS fac_name, fac.facid, bkg.slots, bkg.starttime, bkg.memid, fac.guestcost, fac.membercost,
CASE WHEN bkg.memid = 0
	THEN bkg.slots * fac.guestcost
	ELSE bkg.slots * fac.membercost
	END AS slot_cost
FROM `Facilities` fac, `Bookings` bkg
WHERE fac.facid = bkg.facid) a
GROUP BY a.facid) b
WHERE b.Total_Revenue < 1000
ORDER BY b.Total_Revenue DESC

/*
fac_name	Total_Revenue	
Pool Table	270.0
Snooker Table	240.0
Table Tennis	180.0
*/