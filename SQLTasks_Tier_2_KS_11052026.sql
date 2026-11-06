/* Country Club Case Study - Tier 2
   Simple student solutions
*/

/* PART 1: PHPMyAdmin / MySQL */

/* Q1: List facilities that charge members a fee. */
SELECT name
FROM Facilities
WHERE membercost > 0;


/* Q2: How many facilities do not charge members a fee? */
SELECT COUNT(*) AS free_facilities
FROM Facilities
WHERE membercost = 0;


/* Q3: Facilities that charge a member fee less than 20%
   of monthly maintenance. */
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0
  AND membercost < 0.20 * monthlymaintenance;


/* Q4: Retrieve facilities with ID 1 and 5 without using OR. */
SELECT *
FROM Facilities
WHERE facid IN (1, 5);


/* Q5: Label each facility as cheap or expensive.
   Expensive means monthly maintenance is more than $100. */
SELECT name,
       monthlymaintenance,
       CASE
           WHEN monthlymaintenance > 100 THEN 'expensive'
           ELSE 'cheap'
       END AS cost_label
FROM Facilities;


/* Q6: Find the last member(s) who signed up without LIMIT. */
SELECT firstname, surname
FROM Members
WHERE joindate = (
    SELECT MAX(joindate)
    FROM Members
);


/* Q7: List members who used a tennis court.
   Exclude the guest account and remove duplicates. */
SELECT DISTINCT
       f.name AS facility,
       CONCAT(m.firstname, ' ', m.surname) AS member
FROM Bookings AS b
JOIN Facilities AS f
    ON b.facid = f.facid
JOIN Members AS m
    ON b.memid = m.memid
WHERE f.name LIKE 'Tennis Court%'
  AND b.memid <> 0
ORDER BY member;


/* Q8: Bookings on 2012-09-14 costing more than $30.
   Do not use a subquery. */
SELECT
       f.name AS facility,
       CONCAT(m.firstname, ' ', m.surname) AS member,
       b.slots *
       CASE
           WHEN b.memid = 0 THEN f.guestcost
           ELSE f.membercost
       END AS cost
FROM Bookings AS b
JOIN Facilities AS f
    ON b.facid = f.facid
JOIN Members AS m
    ON b.memid = m.memid
WHERE DATE(b.starttime) = '2012-09-14'
  AND b.slots *
      CASE
          WHEN b.memid = 0 THEN f.guestcost
          ELSE f.membercost
      END > 30
ORDER BY cost DESC;


/* Q9: Same result as Q8, but use a subquery. */
SELECT facility, member, cost
FROM (
    SELECT
           f.name AS facility,
           CONCAT(m.firstname, ' ', m.surname) AS member,
           b.slots *
           CASE
               WHEN b.memid = 0 THEN f.guestcost
               ELSE f.membercost
           END AS cost
    FROM Bookings AS b
    JOIN Facilities AS f
        ON b.facid = f.facid
    JOIN Members AS m
        ON b.memid = m.memid
    WHERE DATE(b.starttime) = '2012-09-14'
) AS booking_costs
WHERE cost > 30
ORDER BY cost DESC;


/* PART 2: SQLite
   These same queries are also shown and run in the Jupyter notebook.
*/

/* Q10: Facilities with total revenue less than 1000. */
SELECT
       f.name AS facility,
       SUM(
           CASE
               WHEN b.memid = 0 THEN b.slots * f.guestcost
               ELSE b.slots * f.membercost
           END
       ) AS total_revenue
FROM Facilities AS f
JOIN Bookings AS b
    ON f.facid = b.facid
GROUP BY f.facid, f.name
HAVING total_revenue < 1000
ORDER BY total_revenue;


/* Q11: Members and who recommended them.
   LEFT JOIN keeps members who were not recommended by anyone. */
SELECT
       m.surname,
       m.firstname,
       r.surname AS recommender_surname,
       r.firstname AS recommender_firstname
FROM Members AS m
LEFT JOIN Members AS r
    ON m.recommendedby = r.memid
WHERE m.memid <> 0
ORDER BY m.surname, m.firstname;


/* Q12: Facility usage by member, excluding guests.
   Usage is measured by total booked slots. */
SELECT
       f.name AS facility,
       m.firstname || ' ' || m.surname AS member,
       SUM(b.slots) AS total_slots
FROM Bookings AS b
JOIN Facilities AS f
    ON b.facid = f.facid
JOIN Members AS m
    ON b.memid = m.memid
WHERE b.memid <> 0
GROUP BY f.facid, f.name, m.memid, m.firstname, m.surname
ORDER BY f.name, m.surname, m.firstname;


/* Q13: Facility usage by month, excluding guests.
   Usage is measured by total booked slots. */
SELECT
       f.name AS facility,
       strftime('%m', b.starttime) AS month,
       SUM(b.slots) AS total_slots
FROM Bookings AS b
JOIN Facilities AS f
    ON b.facid = f.facid
WHERE b.memid <> 0
GROUP BY f.facid, f.name, strftime('%m', b.starttime)
ORDER BY month, f.name;
