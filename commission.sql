mysql> CREATE DATABASE commission;
Query OK, 1 row affected (0.00 sec)

mysql> USE commission;
Database changed
mysql> CREATE TABLE departments
    -> (
    -> id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    -> name VARCHAR(20)
    -> )
    -> ENGINE=INNODB;
Query OK, 0 rows affected (0.69 sec)

mysql> INSERT INTO departments
    -> VALUES (NULL, 'Banking'),
    -> (NULL, 'Insurance'),
    -> (NULL, 'Services');
Query OK, 3 rows affected (0.36 sec)
Records: 3  Duplicates: 0  Warnings: 0

////////////////////////////////////////////////////////////////////////////
mysql> CREATE TABLE employees
    -> (
    -> id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    -> name VARCHAR(30),
    -> salary INT,
    -> department_id INT NOT NULL REFERENCES departments (id)
    -> )
    -> ENGINE=INNODB;
Query OK, 0 rows affected (0.87 sec)

mysql> INSERT INTO employees(name, salary, department_id)
    -> VALUES ('Chris Gayle', 1000000, 1),
    -> ('Michael Clarke', 800000, 2),
    -> ('Rahul Dravid', 700000, 1),
    -> ('Ricky Pointing', 600000, 2),
    -> ('Albie Morkel', 650000, 2),
    -> ('Wasim Akram', 750000, 3);
Query OK, 6 rows affected (0.08 sec)
Records: 6  Duplicates: 0  Warnings: 0

///////////////////////////////////////////////////////////////////////
mysql> CREATE TABLE commissions
    -> (
    -> id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    -> employee_id INT REFERENCES employees (id),
    -> commission_amount INT
    -> )
    -> ENGINE=INNODB;
Query OK, 0 rows affected (0.69 sec)

mysql> INSERT INTO commissions(employee_id, commission_amount)
    -> VALUES (1, 5000),
    -> (2, 3000),
    -> (3, 4000),
    -> (1, 4000),
    -> (2, 3000),
    -> (4, 2000),
    -> (5, 1000),
    -> (6, 5000);
Query OK, 8 rows affected (0.09 sec)
Records: 8  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX index_commission ON commissions (commission_amount);
Query OK, 0 rows affected (0.38 sec)
Records: 0  Duplicates: 0  Warnings: 0

///////////////////////////////////////////////////////////////////////

1)
mysql> SELECT employee.name, MAX(total_commission)
    -> FROM (
    -> SELECT employee_id, SUM(commission_amount) AS total_commission
    -> FROM commissions
    -> GROUP BY employee_id
    -> ) AS temp JOIN employees AS employee
    -> ON employee.id= temp.employee_id;
+-------------+-----------------------+
| name        | max(total_commission) |
+-------------+-----------------------+
| Chris Gayle |                  9000 |
+-------------+-----------------------+
1 row in set (0.00 sec)


2)
mysql> SELECT *
    -> FROM employees
    -> ORDER BY salary DESC
    -> LIMIT 3,1;
+----+--------------+--------+---------------+
| id | name         | salary | department_id |
+----+--------------+--------+---------------+
|  3 | Rahul Dravid | 700000 |             1 |
+----+--------------+--------+---------------+
1 row in set (0.00 sec)


3)
mysql> SELECT department.name, SUM(temp.total_commission) AS department_commission
    -> FROM
    -> (
    ->   SELECT employee_id, SUM(commission_amount) AS total_commission
    ->   FROM commissions
    ->   GROUP BY employee_id
    -> )
    -> AS temp JOIN employees AS e
    -> ON e.id=temp.employee_id
    -> JOIN departments AS department
    -> ON e.department_id=department.id
    -> GROUP BY e.department_id
    -> ORDER BY department_commission DESC
    -> LIMIT 1;
+---------+-----------------------+
| name    | department_commission |
+---------+-----------------------+
| Banking |                 13000 |
+---------+-----------------------+
1 row in set (0.00 sec)



4)
mysql> SELECT GROUP_CONCAT(e.name) AS players, total
    -> FROM (
    -> SELECT employee_id, SUM(commission_amount) AS total
    -> FROM commissions
    -> GROUP BY employee_id
    -> HAVING total > 3000
    -> ) AS temp JOIN employees AS e
    -> ON temp.employee_id=e.id
    -> GROUP BY temp.total;
+----------------+-------+
| players        | total |
+----------------+-------+
| Rahul Dravid   |  4000 |
| Wasim Akram    |  5000 |
| Michael Clarke |  6000 |
| Chris Gayle    |  9000 |
+----------------+-------+
4 rows in set (0.00 sec)
