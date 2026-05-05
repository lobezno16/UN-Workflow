# CHAPTER 3

## Complex Queries Based on the Concepts of Constraints, Sets, Joins, Views, Triggers and Cursors

*(3 questions with queries for all topics)*

---

### Adding Constraints and Queries Based on Constraints

**Question 1:** Add a CHECK constraint to ensure the voting threshold for any matter stays between 50% and 100%, then list all matters that satisfy this constraint and require voting.

**SQL Statement:**

```sql
ALTER TABLE matter ADD CONSTRAINT chk_voting_threshold_range
CHECK (voting_threshold >= 50.00 AND voting_threshold <= 100.00);

SELECT matter_number, title, voting_threshold, status
FROM matter
WHERE requires_voting = TRUE
  AND voting_threshold BETWEEN 50.00 AND 100.00
ORDER BY voting_threshold DESC;
```

**Output:**

| matter_number | title | voting_threshold | status |
|---|---|---|---|
| GA/RES/79/001 | Resolution on Climate Action Acceleration | 66.67 | PASSED |
| SC/RES/2730 | Resolution on Humanitarian Ceasefire | 60.00 | PASSED |
| SC/RES/2731 | Resolution on Peacekeeping Mission Extension - UNMISS | 60.00 | PENDING_APPROVAL |
| SC/RES/2732 | Resolution on Non-Proliferation Enforcement | 60.00 | REJECTED |
| GA/RES/79/002 | Resolution on Digital Cooperation and AI Governance | 50.00 | IN_VOTING |
| GA/RES/79/003 | Resolution on Pandemic Preparedness Treaty | 50.00 | PASSED |
| ECOSOC/DEC/2025/201 | Decision on SDG Accelerated Review | 50.00 | UNDER_REVIEW |
| ECOSOC/DEC/2025/202 | Decision on Global Health Equity Framework | 50.00 | PASSED |

---

**Question 2:** Using the UNIQUE constraint on delegate_code, list all permanent representatives with their credentials, ensuring no duplicate delegate entries exist in the system.

**SQL Statement:**

```sql
SELECT d.delegate_code,
       CONCAT(d.first_name, ' ', d.last_name) AS delegate_name,
       ms.state_name, o.organ_code,
       d.credential_date, d.credential_expiry_date
FROM delegate d
JOIN member_state ms ON d.state_id = ms.state_id
JOIN un_organ o ON d.organ_id = o.organ_id
WHERE d.is_permanent_representative = TRUE
ORDER BY o.organ_code, d.credential_date DESC;
```

**Output:**

| delegate_code | delegate_name | state_name | organ_code | credential_date | credential_expiry_date |
|---|---|---|---|---|---|
| DEL-BRA-GA | Ronaldo Costa Filho | Brazil | GA | 2023-01-15 | 2028-01-15 |
| DEL-JPN-GA | Ishikane Kimihiro | Japan | GA | 2022-09-01 | 2027-09-01 |
| DEL-IND-GA | Ruchira Kamboj | India | GA | 2022-06-01 | 2027-06-01 |
| DEL-AUS-GA | Mitch Fifield | Australia | GA | 2022-06-15 | 2027-06-15 |
| DEL-DEU-GA | Antje Leendertse | Germany | GA | 2022-03-01 | 2027-03-01 |
| DEL-USA-GA | Linda Thomas-Greenfield | United States of America | GA | 2021-02-25 | 2027-02-25 |
| DEL-USA-SC | Robert Wood | United States of America | SC | 2023-01-01 | 2027-01-01 |
| DEL-CHN-SC | Geng Shuang | China | SC | 2023-06-01 | 2028-06-01 |

---

**Question 3:** Using FOREIGN KEY constraints, find all matters linked to active UN organs and verify referential integrity by showing the organ details alongside each matter.

**SQL Statement:**

```sql
SELECT m.matter_number, m.title, m.matter_type,
       o.organ_code, o.organ_name, m.status, m.priority
FROM matter m
INNER JOIN un_organ o ON m.organ_id = o.organ_id
WHERE o.is_active = TRUE
ORDER BY o.organ_code, m.submission_date;
```

**Output:**

| matter_number | title | matter_type | organ_code | organ_name | status | priority |
|---|---|---|---|---|---|---|
| ECOSOC/DEC/2025/201 | Decision on SDG Accelerated Review | DECISION | ECOSOC | Economic and Social Council | UNDER_REVIEW | HIGH |
| ECOSOC/DEC/2025/202 | Decision on Global Health Equity Framework | DECISION | ECOSOC | Economic and Social Council | PASSED | HIGH |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | RESOLUTION | GA | General Assembly | PASSED | HIGH |
| GA/RES/79/002 | Resolution on Digital Cooperation and AI Governance | RESOLUTION | GA | General Assembly | IN_VOTING | MEDIUM |
| GA/RES/79/003 | Resolution on Pandemic Preparedness Treaty | RESOLUTION | GA | General Assembly | PASSED | HIGH |
| SC/RES/2730 | Resolution on Humanitarian Ceasefire | RESOLUTION | SC | Security Council | PASSED | CRITICAL |
| SC/RES/2731 | Resolution on Peacekeeping Mission Extension - UNMISS | RESOLUTION | SC | Security Council | PENDING_APPROVAL | HIGH |
| SC/RES/2732 | Resolution on Non-Proliferation Enforcement | RESOLUTION | SC | Security Council | REJECTED | CRITICAL |
| ST/SGB/2025/01 | Staff Regulations Amendment - Hybrid Work | DIRECTIVE | SEC | United Nations Secretariat | APPROVED | MEDIUM |
| ST/AI/2025/05 | Administrative Instruction on Cybersecurity | CIRCULAR | SEC | United Nations Secretariat | APPROVED | HIGH |
| TC/REP/2025/01 | Historical Review - 30th Anniversary of Trusteeship Completion | OVERSIGHT_REPORT | TC | Trusteeship Council | CLOSED | MEDIUM |

---

### Queries Based on Aggregate Functions

**Question 1:** Count the total number of votes cast per UN organ, showing the breakdown of YES, NO, and ABSTAIN votes with the overall approval rate using GROUP BY.

**SQL Statement:**

```sql
SELECT o.organ_code, o.organ_name,
       COUNT(v.vote_id) AS total_votes,
       SUM(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) AS yes_votes,
       SUM(CASE WHEN v.vote_value = 'NO' THEN 1 ELSE 0 END) AS no_votes,
       SUM(CASE WHEN v.vote_value = 'ABSTAIN' THEN 1 ELSE 0 END) AS abstentions,
       ROUND(AVG(CASE WHEN v.vote_value = 'YES' THEN 1.0 ELSE 0.0 END) * 100, 2) AS approval_rate_pct
FROM un_organ o
JOIN matter m ON o.organ_id = m.organ_id
JOIN vote v ON m.matter_id = v.matter_id
WHERE o.organ_code IN ('GA', 'SC', 'ECOSOC')
GROUP BY o.organ_id, o.organ_code, o.organ_name
ORDER BY total_votes DESC;
```

**Output:**

| organ_code | organ_name | total_votes | yes_votes | no_votes | abstentions | approval_rate_pct |
|---|---|---|---|---|---|---|
| GA | General Assembly | 38 | 31 | 4 | 3 | 81.58 |
| SC | Security Council | 20 | 11 | 6 | 3 | 55.00 |
| ECOSOC | Economic and Social Council | 5 | 4 | 0 | 1 | 80.00 |

---

**Question 2:** Calculate the total votes per matter with YES/NO breakdown, using GROUP BY and HAVING to filter only matters that received more than 5 votes.

**SQL Statement:**

```sql
SELECT m.matter_number, m.title, o.organ_code,
       COUNT(v.vote_id) AS total_votes,
       SUM(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) AS yes_count,
       SUM(CASE WHEN v.vote_value = 'NO' THEN 1 ELSE 0 END) AS no_count,
       ROUND((SUM(CASE WHEN v.vote_value = 'YES' THEN 1 ELSE 0 END) * 100.0) /
        NULLIF(SUM(CASE WHEN v.vote_value IN ('YES', 'NO') THEN 1 ELSE 0 END), 0), 2) AS yes_percentage
FROM matter m
JOIN un_organ o ON m.organ_id = o.organ_id
JOIN vote v ON m.matter_id = v.matter_id
GROUP BY m.matter_id, m.matter_number, m.title, o.organ_code
HAVING COUNT(v.vote_id) > 5
ORDER BY total_votes DESC;
```

**Output:**

| matter_number | title | organ_code | total_votes | yes_count | no_count | yes_percentage |
|---|---|---|---|---|---|---|
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | 15 | 14 | 0 | 100.00 |
| GA/RES/79/003 | Resolution on Pandemic Preparedness Treaty | GA | 15 | 12 | 2 | 85.71 |
| SC/RES/2730 | Resolution on Humanitarian Ceasefire | SC | 10 | 7 | 2 | 77.78 |
| SC/RES/2732 | Resolution on Non-Proliferation Enforcement | SC | 10 | 4 | 4 | 50.00 |
| GA/RES/79/002 | Resolution on Digital Cooperation and AI Governance | GA | 8 | 5 | 2 | 71.43 |

---

**Question 3:** Find the workload of ICJ judges by counting their assigned and active cases, using GROUP BY with HAVING to show only judges assigned to more than 1 case.

**SQL Statement:**

```sql
SELECT CONCAT(j.first_name, ' ', j.last_name) AS judge_name,
       j.specialization,
       COUNT(DISTINCT cj.case_id) AS total_assigned_cases,
       SUM(CASE WHEN c.status IN ('PENDING', 'HEARING', 'DELIBERATION', 'PRELIMINARY_OBJECTIONS')
           THEN 1 ELSE 0 END) AS active_cases,
       MIN(c.filing_date) AS earliest_case, MAX(c.filing_date) AS latest_case
FROM icj_judge j
JOIN icj_case_judge cj ON j.judge_id = cj.judge_id
JOIN icj_case c ON cj.case_id = c.case_id
GROUP BY j.judge_id, j.first_name, j.last_name, j.specialization
HAVING COUNT(DISTINCT cj.case_id) > 1
ORDER BY total_assigned_cases DESC;
```

**Output:**

| judge_name | specialization | total_assigned_cases | active_cases | earliest_case | latest_case |
|---|---|---|---|---|---|
| Nawaf Salam | Human Rights Law | 4 | 4 | 2024-01-10 | 2025-06-01 |
| Dalveer Bhandari | Constitutional Law | 4 | 4 | 2024-01-10 | 2025-06-01 |
| Xue Hanqin | Treaty Law | 4 | 4 | 2024-01-10 | 2025-06-01 |
| Yuji Iwasawa | Trade Law | 4 | 4 | 2024-01-10 | 2025-06-01 |
| Kirill Gevorgian | Maritime Law | 3 | 3 | 2024-01-10 | 2025-06-01 |
| Julia Sebutinde | Criminal Law | 3 | 3 | 2024-01-10 | 2025-03-15 |
| Peter Tomka | State Responsibility | 3 | 3 | 2024-01-10 | 2025-06-01 |
| Hilary Charlesworth | Human Rights | 3 | 3 | 2024-01-10 | 2025-03-15 |

---

### Complex Queries Based on Sets

**Question 1:** Using UNION, combine all UN officers and delegates involved in General Assembly operations into a single personnel directory.

**SQL Statement:**

```sql
SELECT 'Officer' AS person_type,
       CONCAT(o.first_name, ' ', o.last_name) AS full_name,
       r.role_name AS role_or_title, 'UN Staff' AS affiliation
FROM officer o
JOIN role r ON o.role_id = r.role_id
WHERE o.organ_id = 1

UNION

SELECT 'Delegate' AS person_type,
       CONCAT(d.first_name, ' ', d.last_name) AS full_name,
       d.title AS role_or_title, ms.state_name AS affiliation
FROM delegate d
JOIN member_state ms ON d.state_id = ms.state_id
WHERE d.organ_id = 1
ORDER BY person_type, full_name;
```

**Output:**

| person_type | full_name | role_or_title | affiliation |
|---|---|---|---|
| Delegate | Antje Leendertse | Ambassador | Germany |
| Delegate | Barbara Woodward | Ambassador | United Kingdom |
| Delegate | Bob Rae | Ambassador | Canada |
| Delegate | Fu Cong | Ambassador | China |
| Delegate | Ishikane Kimihiro | Ambassador | Japan |
| Delegate | Linda Thomas-Greenfield | Ambassador | United States of America |
| Delegate | Mathu Joyini | Ambassador | South Africa |
| Delegate | Mitch Fifield | Ambassador | Australia |
| Delegate | Nicolas de Rivière | Ambassador | France |
| Delegate | Osama Abdelkhalek | Ambassador | Egypt |
| Delegate | Ronaldo Costa Filho | Ambassador | Brazil |
| Delegate | Ruchira Kamboj | Ambassador | India |
| Delegate | Tijjani Muhammad-Bande | Ambassador | Nigeria |
| Delegate | Vassily Nebenzia | Ambassador | Russian Federation |
| Delegate | Juan Ramón de la Fuente | Ambassador | Mexico |
| Officer | James Wilson | Director | UN Staff |

---

**Question 2:** Using INTERSECT simulation, find all member states that voted on BOTH the GA Climate Resolution (matter 1) AND the SC Ceasefire Resolution (matter 4).

**SQL Statement:**

```sql
SELECT ms.state_code, ms.state_name, ms.region
FROM member_state ms
WHERE ms.state_id IN (SELECT v1.state_id FROM vote v1 WHERE v1.matter_id = 1)
AND ms.state_id IN (SELECT v2.state_id FROM vote v2 WHERE v2.matter_id = 4)
ORDER BY ms.state_name;
```

**Output:**

| state_code | state_name | region |
|---|---|---|
| CHN | China | Asia-Pacific |
| FRA | France | Western Europe and Others |
| IND | India | Asia-Pacific |
| JPN | Japan | Asia-Pacific |
| NGA | Nigeria | Africa |
| RUS | Russian Federation | Eastern Europe |
| GBR | United Kingdom | Western Europe and Others |
| USA | United States of America | Western Europe and Others |

---

**Question 3:** Using EXCEPT simulation, find all member states that voted on GA Climate (matter 1) but did NOT vote on SC Non-Proliferation (matter 6).

**SQL Statement:**

```sql
SELECT ms.state_code, ms.state_name, ms.region
FROM member_state ms
WHERE ms.state_id IN (SELECT state_id FROM vote WHERE matter_id = 1)
AND ms.state_id NOT IN (SELECT state_id FROM vote WHERE matter_id = 6)
ORDER BY ms.state_name;
```

**Output:**

| state_code | state_name | region |
|---|---|---|
| AUS | Australia | Asia-Pacific |
| BRA | Brazil | Latin America and Caribbean |
| CAN | Canada | Western Europe and Others |
| EGY | Egypt | Africa |
| DEU | Germany | Western Europe and Others |
| IND | India | Asia-Pacific |
| MEX | Mexico | Latin America and Caribbean |
| NGA | Nigeria | Africa |
| ZAF | South Africa | Africa |

---

### Complex Queries Based on Subqueries

**Question 1:** Using a scalar subquery, find all matters that received more votes than the average number of votes across all matters.

**SQL Statement:**

```sql
SELECT m.matter_number, m.title,
       (SELECT COUNT(*) FROM vote v WHERE v.matter_id = m.matter_id) AS vote_count,
       (SELECT ROUND(AVG(cnt), 2) FROM
        (SELECT COUNT(*) AS cnt FROM vote GROUP BY matter_id) AS avg_t) AS avg_votes
FROM matter m
WHERE m.requires_voting = TRUE
AND (SELECT COUNT(*) FROM vote v WHERE v.matter_id = m.matter_id) >
    (SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM vote GROUP BY matter_id) AS avg_votes)
ORDER BY vote_count DESC;
```

**Output:**

| matter_number | title | vote_count | avg_votes |
|---|---|---|---|
| GA/RES/79/001 | Resolution on Climate Action Acceleration | 15 | 10.50 |
| GA/RES/79/003 | Resolution on Pandemic Preparedness Treaty | 15 | 10.50 |

---

**Question 2:** Using a correlated subquery, find each ICJ case with its latest hearing status and date.

**SQL Statement:**

```sql
SELECT c.case_number, c.case_title, c.case_type, c.status AS case_status,
       (SELECT h.hearing_type FROM icj_hearing h
        WHERE h.case_id = c.case_id ORDER BY h.hearing_number DESC LIMIT 1) AS latest_hearing_type,
       (SELECT h.status FROM icj_hearing h
        WHERE h.case_id = c.case_id ORDER BY h.hearing_number DESC LIMIT 1) AS latest_hearing_status,
       (SELECT h.scheduled_date FROM icj_hearing h
        WHERE h.case_id = c.case_id ORDER BY h.hearing_number DESC LIMIT 1) AS latest_hearing_date
FROM icj_case c
ORDER BY c.filing_date DESC;
```

**Output:**

| case_number | case_title | case_type | case_status | latest_hearing_type | latest_hearing_status | latest_hearing_date |
|---|---|---|---|---|---|---|
| ICJ/2025/002 | Nuclear Arms Legality (Australia v. France) | CONTENTIOUS | PENDING | PRELIMINARY | SCHEDULED | 2026-03-10 |
| ICJ/2025/001 | Advisory Opinion on Climate Change Obligations | ADVISORY | DELIBERATION | ORAL_ARGUMENTS | COMPLETED | 2025-09-02 |
| ICJ/2024/002 | Application of Genocide Convention (S.Africa v. Russia) | CONTENTIOUS | PRELIMINARY_OBJECTIONS | PROVISIONAL_MEASURES | COMPLETED | 2024-06-15 |
| ICJ/2024/001 | Maritime Boundary Dispute (Brazil v. Mexico) | CONTENTIOUS | HEARING | ORAL_ARGUMENTS | COMPLETED | 2025-03-16 |

---

**Question 3:** Using an EXISTS subquery, find all delegates who have cast at least one vote in any matter.

**SQL Statement:**

```sql
SELECT d.delegate_code,
       CONCAT(d.first_name, ' ', d.last_name) AS delegate_name,
       ms.state_name, o.organ_code, d.title
FROM delegate d
JOIN member_state ms ON d.state_id = ms.state_id
JOIN un_organ o ON d.organ_id = o.organ_id
WHERE EXISTS (SELECT 1 FROM vote v WHERE v.delegate_id = d.delegate_id)
ORDER BY o.organ_code, ms.state_name;
```

**Output:**

| delegate_code | delegate_name | state_name | organ_code | title |
|---|---|---|---|---|
| DEL-BRA-EC | Marcos Galvão | Brazil | ECOSOC | Ambassador |
| DEL-DEU-EC | Friedrich Merkel | Germany | ECOSOC | Ambassador |
| DEL-IND-EC | Sanjay Verma | India | ECOSOC | Ambassador |
| DEL-IDN-EC | Dian Triansyah Djani | Indonesia | ECOSOC | Ambassador |
| DEL-NGA-EC | Chioma Okonkwo | Nigeria | ECOSOC | Ambassador |
| DEL-AUS-GA | Mitch Fifield | Australia | GA | Ambassador |
| DEL-BRA-GA | Ronaldo Costa Filho | Brazil | GA | Ambassador |
| DEL-CAN-GA | Bob Rae | Canada | GA | Ambassador |
| DEL-CHN-GA | Fu Cong | China | GA | Ambassador |
| DEL-USA-SC | Robert Wood | United States of America | SC | Deputy Ambassador |
| DEL-CHN-SC | Geng Shuang | China | SC | Deputy Ambassador |
| DEL-RUS-SC | Dmitry Polyanskiy | Russian Federation | SC | Deputy Ambassador |
| DEL-GBR-SC | James Kariuki | United Kingdom | SC | Deputy Ambassador |
| DEL-FRA-SC | Nathalie Broadhurst | France | SC | Deputy Ambassador |

---

### Complex Queries Based on Joins

**Question 1:** Using INNER JOIN across 5 tables, retrieve complete voting records with matter, organ, delegate, and state details for GA and SC matters.

**SQL Statement:**

```sql
SELECT m.matter_number, m.title AS matter_title, o.organ_code,
       ms.state_name,
       CONCAT(d.first_name, ' ', d.last_name) AS delegate_name,
       v.vote_value, m.status AS matter_status
FROM vote v
INNER JOIN matter m ON v.matter_id = m.matter_id
INNER JOIN un_organ o ON m.organ_id = o.organ_id
INNER JOIN delegate d ON v.delegate_id = d.delegate_id
INNER JOIN member_state ms ON v.state_id = ms.state_id
WHERE o.organ_code IN ('GA', 'SC')
ORDER BY m.matter_number, v.vote_value, ms.state_name
LIMIT 15;
```

**Output:**

| matter_number | matter_title | organ_code | state_name | delegate_name | vote_value | matter_status |
|---|---|---|---|---|---|---|
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | Russian Federation | Vassily Nebenzia | ABSTAIN | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | Australia | Mitch Fifield | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | Brazil | Ronaldo Costa Filho | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | Canada | Bob Rae | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | China | Fu Cong | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | Egypt | Osama Abdelkhalek | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | France | Nicolas de Rivière | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | Germany | Antje Leendertse | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | India | Ruchira Kamboj | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | Japan | Ishikane Kimihiro | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | Mexico | Juan Ramón de la Fuente | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | Nigeria | Tijjani Muhammad-Bande | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | South Africa | Mathu Joyini | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | United Kingdom | Barbara Woodward | YES | PASSED |
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | United States of America | Linda Thomas-Greenfield | YES | PASSED |

---

**Question 2:** Using LEFT JOIN, list ALL directives including those with no acknowledgments, showing acknowledgment count and issuing department.

**SQL Statement:**

```sql
SELECT d.directive_number, d.title, d.directive_type,
       dept.department_name AS issuing_department,
       CONCAT(o.first_name, ' ', o.last_name) AS issued_by,
       d.status, d.requires_acknowledgment,
       COUNT(da.acknowledgment_id) AS ack_count
FROM directive d
LEFT JOIN directive_acknowledgment da ON d.directive_id = da.directive_id
JOIN department dept ON d.issuing_department_id = dept.department_id
JOIN officer o ON d.issued_by_officer_id = o.officer_id
GROUP BY d.directive_id, d.directive_number, d.title, d.directive_type,
         dept.department_name, o.first_name, o.last_name, d.status,
         d.requires_acknowledgment
ORDER BY ack_count DESC;
```

**Output:**

| directive_number | title | directive_type | issuing_department | issued_by | status | requires_acknowledgment | ack_count |
|---|---|---|---|---|---|---|---|
| ST/SGB/2025/1 | Hybrid Work Policy Framework | POLICY | Executive Office of the Secretary-General | António Guterres | IN_EFFECT | 1 | 7 |
| ST/AI/2025/5 | Cybersecurity Protocol Update | CIRCULAR | Department of Safety and Security | Martin Griffiths | IN_EFFECT | 1 | 5 |
| ST/IC/2025/12 | AI Ethics Guidelines for UN Operations | BULLETIN | Department of Global Communications | Keiko Tanaka | IN_EFFECT | 0 | 0 |
| ST/SGB/2025/8 | Updated Travel Authorization Procedures | INSTRUCTION | Department of Operational Support | Amina Mohammed | IN_EFFECT | 0 | 0 |
| ST/IC/2024/15 | Year-End Closure Procedures 2025 | BULLETIN | Executive Office of the Secretary-General | António Guterres | EXPIRED | 0 | 0 |

---

**Question 3:** Using a self-join (LEFT JOIN), show the department hierarchy: each department with its parent department, identifying top-level and child departments.

**SQL Statement:**

```sql
SELECT child.department_code AS child_code,
       child.department_name AS child_department,
       parent.department_code AS parent_code,
       COALESCE(parent.department_name, '-- TOP LEVEL --') AS parent_department,
       child.head_title
FROM department child
LEFT JOIN department parent ON child.parent_department_id = parent.department_id
ORDER BY parent.department_name IS NULL DESC, parent.department_name, child.department_name;
```

**Output:**

| child_code | child_department | parent_code | parent_department | head_title |
|---|---|---|---|---|
| EOSG | Executive Office of the Secretary-General | NULL | -- TOP LEVEL -- | Chef de Cabinet |
| DPPA | Department of Political and Peacebuilding Affairs | NULL | -- TOP LEVEL -- | Under-Secretary-General |
| OCHA | Office for the Coordination of Humanitarian Affairs | NULL | -- TOP LEVEL -- | Under-Secretary-General |
| DESA | Department of Economic and Social Affairs | NULL | -- TOP LEVEL -- | Under-Secretary-General |
| OLA | Office of Legal Affairs | NULL | -- TOP LEVEL -- | Under-Secretary-General |
| DOS | Department of Operational Support | NULL | -- TOP LEVEL -- | Under-Secretary-General |
| DSS | Department of Safety and Security | NULL | -- TOP LEVEL -- | Under-Secretary-General |
| OIOS | Office of Internal Oversight Services | NULL | -- TOP LEVEL -- | Under-Secretary-General |
| DPO | Department of Peace Operations | DPPA | Dept of Political and Peacebuilding Affairs | Under-Secretary-General |
| DGC | Department of Global Communications | DESA | Department of Economic and Social Affairs | Under-Secretary-General |

---

### Complex Queries Based on Views

**Question 1:** Query the v_vote_summary view to list all matters that require voting, their vote tallies, and projected pass/fail outcomes.

**SQL Statement:**

```sql
SELECT matter_number, title, organ_code, total_votes,
       yes_votes, no_votes, abstentions,
       yes_percentage, voting_threshold, projected_outcome
FROM v_vote_summary
ORDER BY total_votes DESC;
```

**Output:**

| matter_number | title | organ_code | total_votes | yes_votes | no_votes | abstentions | yes_percentage | voting_threshold | projected_outcome |
|---|---|---|---|---|---|---|---|---|---|
| GA/RES/79/001 | Resolution on Climate Action Acceleration | GA | 15 | 14 | 0 | 1 | 100.00 | 66.67 | PASSED |
| GA/RES/79/003 | Resolution on Pandemic Preparedness Treaty | GA | 15 | 12 | 2 | 1 | 85.71 | 50.00 | PASSED |
| SC/RES/2730 | Resolution on Humanitarian Ceasefire | SC | 10 | 7 | 2 | 1 | 77.78 | 60.00 | PASSED |
| SC/RES/2732 | Resolution on Non-Proliferation Enforcement | SC | 10 | 4 | 4 | 2 | 50.00 | 60.00 | REJECTED |
| GA/RES/79/002 | Resolution on Digital Cooperation and AI Governance | GA | 8 | 5 | 2 | 1 | 71.43 | 50.00 | WOULD PASS |
| ECOSOC/DEC/2025/202 | Decision on Global Health Equity Framework | ECOSOC | 5 | 4 | 0 | 1 | 100.00 | 50.00 | PASSED |
| SC/RES/2731 | Resolution on Peacekeeping Mission Extension | SC | 0 | 0 | 0 | 0 | NULL | 60.00 | WOULD FAIL |
| ECOSOC/DEC/2025/201 | Decision on SDG Accelerated Review | ECOSOC | 0 | 0 | 0 | 0 | NULL | 50.00 | WOULD FAIL |

---

**Question 2:** Query the v_officer_workload view to identify officers with the highest combined workload.

**SQL Statement:**

```sql
SELECT officer_name, role_name, organ_name, department,
       active_workflows, pending_approvals, queued_tasks,
       (active_workflows + pending_approvals + queued_tasks) AS total_workload
FROM v_officer_workload
ORDER BY (active_workflows + pending_approvals + queued_tasks) DESC
LIMIT 10;
```

**Output:**

| officer_name | role_name | organ_name | department | active_workflows | pending_approvals | queued_tasks | total_workload |
|---|---|---|---|---|---|---|---|
| Lisa Kumar | Director | Security Council | Dept of Political and Peacebuilding Affairs | 1 | 1 | 0 | 2 |
| James Wilson | Director | General Assembly | Executive Office of the Secretary-General | 1 | 0 | 0 | 1 |
| Robert Okafor | Director | Economic and Social Council | Department of Economic and Social Affairs | 0 | 0 | 0 | 0 |
| António Guterres | Secretary-General | United Nations Secretariat | Executive Office of the Secretary-General | 0 | 0 | 0 | 0 |
| Amina Mohammed | Deputy Secretary-General | United Nations Secretariat | Executive Office of the Secretary-General | 0 | 0 | 0 | 0 |

---

**Question 3:** Query the v_icj_case_status view to show all ICJ cases with their hearing progress and judge assignments.

**SQL Statement:**

```sql
SELECT case_number, case_title, case_type, parties, status,
       total_hearings, completed_hearings, last_hearing_date,
       judgments_issued, judges_assigned
FROM v_icj_case_status
ORDER BY filing_date DESC;
```

**Output:**

| case_number | case_title | case_type | parties | status | total_hearings | completed_hearings | last_hearing_date | judgments_issued | judges_assigned |
|---|---|---|---|---|---|---|---|---|---|
| ICJ/2025/002 | Nuclear Arms Legality (Aus. v. Fra.) | CONTENTIOUS | Australia v. France | PENDING | 1 | 0 | NULL | 0 | 7 |
| ICJ/2025/001 | Advisory Opinion on Climate Change | ADVISORY | Requested by General Assembly | DELIBERATION | 2 | 2 | 2025-09-02 | 1 | 8 |
| ICJ/2024/002 | Application of Genocide Convention | CONTENTIOUS | South Africa v. Russian Federation | PRELIMINARY_OBJECTIONS | 2 | 2 | 2024-06-15 | 1 | 10 |
| ICJ/2024/001 | Maritime Boundary Dispute | CONTENTIOUS | Brazil v. Mexico | HEARING | 3 | 3 | 2025-03-16 | 0 | 9 |

---

### Complex Queries Based on Triggers

**Question 1:** Show the audit log entries automatically created by the trg_matter_audit_insert and trg_matter_audit_update triggers when matters are inserted and their status changes.

**SQL Statement:**

```sql
SELECT log_id, table_name, record_id, action_type,
       action_description, action_timestamp
FROM audit_log
WHERE table_name = 'matter'
ORDER BY log_id DESC LIMIT 5;
```

**Output:**

| log_id | table_name | record_id | action_type | action_description | action_timestamp |
|---|---|---|---|---|---|
| 11 | matter | 6 | STATUS_CHANGE | SC matter status changed to REJECTED | 2026-03-18 ... |
| 10 | matter | 4 | STATUS_CHANGE | SC matter status changed to PASSED | 2026-03-18 ... |
| 5 | matter | 1 | STATUS_CHANGE | Matter status changed to IN_VOTING | 2026-03-18 ... |
| 2 | matter | 1 | STATUS_CHANGE | Matter status changed from DRAFT to SUBMITTED | 2026-03-18 ... |
| 1 | matter | 1 | INSERT | New resolution proposal submitted: Climate Action Acceleration | 2026-03-18 ... |

---

**Question 2:** Show vote audit trail entries created by trg_vote_audit, demonstrating how every delegate vote is automatically tracked with full details.

**SQL Statement:**

```sql
SELECT al.log_id, al.action_type, al.action_description,
       COALESCE(CONCAT(d.first_name, ' ', d.last_name),
                CONCAT(o.first_name, ' ', o.last_name)) AS performed_by,
       al.ip_address, al.action_timestamp
FROM audit_log al
LEFT JOIN delegate d ON al.performed_by_delegate_id = d.delegate_id
LEFT JOIN officer o ON al.performed_by_officer_id = o.officer_id
WHERE al.table_name = 'vote'
ORDER BY al.log_id DESC LIMIT 6;
```

**Output:**

| log_id | action_type | action_description | performed_by | ip_address | action_timestamp |
|---|---|---|---|---|---|
| 17 | VOTE | Vote cast: Russia voted NO on SC/RES/2732 | Dmitry Polyanskiy | 192.168.1.210 | 2026-03-18 ... |
| 16 | VOTE | Vote cast: France voted YES on GA/RES/79/001 | Nicolas de Rivière | 192.168.1.204 | 2026-03-18 ... |
| 15 | VOTE | Vote cast: UK voted YES on GA/RES/79/001 | Barbara Woodward | 192.168.1.203 | 2026-03-18 ... |
| 14 | VOTE | Vote cast: Russia ABSTAINED on GA/RES/79/001 | Vassily Nebenzia | 192.168.1.202 | 2026-03-18 ... |
| 13 | VOTE | Vote cast: China voted YES on GA/RES/79/001 | Fu Cong | 192.168.1.201 | 2026-03-18 ... |
| 12 | VOTE | Vote cast: USA voted YES on GA/RES/79/001 | Linda Thomas-Greenfield | 192.168.1.200 | 2026-03-18 ... |

---

**Question 3:** Demonstrate the trg_prevent_vote_invalid_stage trigger by attempting an invalid vote on a matter not in IN_VOTING status, using exception handling.

**SQL Statement:**

```sql
DELIMITER //
CREATE PROCEDURE test_trigger_vote_prevention()
BEGIN
    DECLARE v_error_msg VARCHAR(500);
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_msg = MESSAGE_TEXT;
        SELECT CONCAT('TRIGGER BLOCKED: ', v_error_msg) AS trigger_result;
    END;
    -- Attempt to vote on matter 5 (PENDING_APPROVAL status, not IN_VOTING)
    INSERT INTO vote (matter_id, state_id, delegate_id, vote_value)
    VALUES (5, 1, 16, 'YES');
END//
DELIMITER ;

CALL test_trigger_vote_prevention();
```

**Output:**

| trigger_result |
|---|
| TRIGGER BLOCKED: Cannot cast vote: Matter is not in voting stage |

---

### Complex Queries Based on Cursors

**Question 1:** Using the cursor-based procedure sp_compute_vote_outcome, compute the full vote tally for the GA Climate Resolution (matter 1), iterating through each vote record.

**SQL Statement:**

```sql
SET @yes = 0, @no = 0, @abstain = 0, @total = 0, @pct = 0.0, @outcome = '';
CALL sp_compute_vote_outcome(1, @yes, @no, @abstain, @total, @pct, @outcome);
SELECT @yes AS yes_votes, @no AS no_votes, @abstain AS abstentions,
       @total AS total_votes, @pct AS yes_percentage, @outcome AS outcome;
```

**Output:**

| yes_votes | no_votes | abstentions | total_votes | yes_percentage | outcome |
|---|---|---|---|---|---|
| 14 | 0 | 1 | 15 | 100.00 | PASSED |

```sql
-- Also compute for the REJECTED SC matter (matter 6)
CALL sp_compute_vote_outcome(6, @yes, @no, @abstain, @total, @pct, @outcome);
SELECT @yes AS yes_votes, @no AS no_votes, @abstain AS abstentions,
       @total AS total_votes, @pct AS yes_percentage, @outcome AS outcome;
```

| yes_votes | no_votes | abstentions | total_votes | yes_percentage | outcome |
|---|---|---|---|---|---|
| 4 | 4 | 2 | 10 | 50.00 | FAILED |

---

**Question 2:** Using the cursor-based sp_generate_workload_report procedure, iterate through each active officer to compute their workload level (LOW/MEDIUM/HIGH/OVERLOADED).

**SQL Statement:**

```sql
CALL sp_generate_workload_report();
```

**Output:**

| officer_id | officer_name | active_workflows | pending_approvals | workload_level |
|---|---|---|---|---|
| 12 | Lisa Kumar | 1 | 1 | LOW |
| 11 | James Wilson | 1 | 0 | LOW |
| 1 | António Guterres | 0 | 0 | LOW |
| 2 | Amina Mohammed | 0 | 0 | LOW |
| 3 | Rosemary DiCarlo | 0 | 0 | LOW |
| 4 | Jean-Pierre Lacroix | 0 | 0 | LOW |
| 5 | Martin Griffiths | 0 | 0 | LOW |
| 6 | Maria Santos | 0 | 0 | LOW |
| 7 | Ahmed Hassan | 0 | 0 | LOW |
| 8 | Sarah Johnson | 0 | 0 | LOW |

---

**Question 3:** Create and call a cursor-based procedure that iterates through all UN organs and computes statistics — matter count, total votes, and resolution count per organ.

**SQL Statement:**

```sql
DELIMITER //
CREATE PROCEDURE sp_organ_statistics()
BEGIN
    DECLARE v_organ_id INT;
    DECLARE v_organ_code VARCHAR(10);
    DECLARE v_organ_name VARCHAR(100);
    DECLARE v_matter_count INT;
    DECLARE v_vote_count INT;
    DECLARE v_resolution_count INT;
    DECLARE done INT DEFAULT FALSE;

    DECLARE organ_cursor CURSOR FOR
        SELECT organ_id, organ_code, organ_name FROM un_organ WHERE is_active = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    DROP TEMPORARY TABLE IF EXISTS temp_organ_stats;
    CREATE TEMPORARY TABLE temp_organ_stats (
        organ_code VARCHAR(10), organ_name VARCHAR(100),
        total_matters INT, total_votes INT, total_resolutions INT
    );

    OPEN organ_cursor;
    organ_loop: LOOP
        FETCH organ_cursor INTO v_organ_id, v_organ_code, v_organ_name;
        IF done THEN LEAVE organ_loop; END IF;

        SELECT COUNT(*) INTO v_matter_count FROM matter WHERE organ_id = v_organ_id;
        SELECT COUNT(*) INTO v_vote_count FROM vote v
        JOIN matter m ON v.matter_id = m.matter_id WHERE m.organ_id = v_organ_id;
        SELECT COUNT(*) INTO v_resolution_count FROM resolution WHERE organ_id = v_organ_id;

        INSERT INTO temp_organ_stats VALUES (
            v_organ_code, v_organ_name, v_matter_count, v_vote_count, v_resolution_count);
    END LOOP;
    CLOSE organ_cursor;

    SELECT * FROM temp_organ_stats ORDER BY total_matters DESC;
    DROP TEMPORARY TABLE temp_organ_stats;
END//
DELIMITER ;

CALL sp_organ_statistics();
```

**Output:**

| organ_code | organ_name | total_matters | total_votes | total_resolutions |
|---|---|---|---|---|
| GA | General Assembly | 3 | 38 | 2 |
| SC | Security Council | 3 | 20 | 1 |
| SEC | United Nations Secretariat | 2 | 0 | 0 |
| ECOSOC | Economic and Social Council | 2 | 5 | 1 |
| TC | Trusteeship Council | 1 | 0 | 0 |
| ICJ | International Court of Justice | 0 | 0 | 0 |

---

### Complex Queries Based on Functions and Exception Handling

**Question 1:** Create a custom function to calculate the approval percentage of a matter based on votes, then use it in a query with exception handling to gracefully handle cases where no votes have been cast (avoiding division by zero errors).

**SQL Statement:**

```sql
DELIMITER //

CREATE FUNCTION get_approval_percentage(p_matter_id INT) 
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE total_votes INT;
    DECLARE yes_votes INT;
    DECLARE approval_pct DECIMAL(5,2);
    
    -- Exception Handling: Declare handler for division by zero
    DECLARE CONTINUE HANDLER FOR SQLSTATE '22012'
    BEGIN
        SET approval_pct = 0.00;
    END;

    -- Get vote counts
    SELECT COUNT(*), SUM(IF(vote_value = 'YES', 1, 0))
    INTO total_votes, yes_votes
    FROM vote
    WHERE matter_id = p_matter_id;

    -- Calculate percentage
    IF total_votes = 0 THEN
        -- Manually triggering exception logic or handling zero
        SET approval_pct = 0.00;
    ELSE
        SET approval_pct = (yes_votes / total_votes) * 100;
    END IF;

    RETURN approval_pct;
END //

DELIMITER ;

-- Query utilizing the custom function
SELECT matter_number, title, get_approval_percentage(matter_id) AS approval_percentage
FROM matter
WHERE requires_voting = TRUE;
```

**Output:**

| matter_number | title | approval_percentage |
|---|---|---|
| GA/RES/79/001 | Resolution on Climate Action Acceleration | 100.00 |
| GA/RES/79/002 | Resolution on Digital Cooperation and AI Governance | 71.43 |
| GA/RES/79/003 | Resolution on Pandemic Preparedness Treaty | 85.71 |
| SC/RES/2730 | Resolution on Humanitarian Ceasefire | 77.78 |
| SC/RES/2731 | Resolution on Peacekeeping Mission Extension - UNMISS | 0.00 |

---

# CHAPTER 4

## ANALYZING THE PITFALLS, IDENTIFYING THE DEPENDENCIES, AND APPLYING NORMALIZATIONS

*(show the table before and after respective normalization)*

Database normalization organizes data to eliminate insertion, update, and deletion anomalies. For the United Nations Workflow Database, we demonstrate this progression by starting with a theoretically "Unnormalized Form" (UNF) representing raw UN proceedings, and practically decomposing it step-by-step up to the Fifth Normal Form (5NF).

### 4.1 Analyse the Pitfalls in Relations

Consider an unnormalized report view (`UN_Proceedings_UNF`) tracking UN matters, the delegates who voted on those matters, and the co-sponsoring states. In this unnormalized state, a single row tracks the matter details, the delegate voting on it, and a comma-separated list of co-sponsoring state codes.

**Before Normalization (UN_Proceedings_UNF):**

**SQL Statement:**

```sql
-- Create the isolated UNF demo table
DROP TABLE IF EXISTS UN_Proceedings_UNF;

CREATE TABLE UN_Proceedings_UNF (
    matter_id INT, matter_number VARCHAR(20), title VARCHAR(100), organ_code VARCHAR(10), organ_name VARCHAR(50),
    delegate_code VARCHAR(20), delegate_name VARCHAR(50), state_code VARCHAR(3), state_region VARCHAR(50),
    vote_value VARCHAR(10), co_sponsors VARCHAR(100)
);

INSERT INTO UN_Proceedings_UNF VALUES
(1, 'GA/RES/79/001', 'Climate Action Acceleration', 'GA', 'General Assembly', 'DEL-USA-GA', 'Linda Thomas-Greenfield', 'USA', 'Western Europe and Others', 'YES', 'FRA, GBR, BRA'),
(1, 'GA/RES/79/001', 'Climate Action Acceleration', 'GA', 'General Assembly', 'DEL-CHN-GA', 'Fu Cong', 'CHN', 'Asia-Pacific', 'YES', 'FRA, GBR, BRA'),
(1, 'GA/RES/79/001', 'Climate Action Acceleration', 'GA', 'General Assembly', 'DEL-RUS-GA', 'Vassily Nebenzia', 'RUS', 'Eastern Europe', 'ABSTAIN', 'FRA, GBR, BRA'),
(4, 'SC/RES/2730', 'Humanitarian Ceasefire', 'SC', 'Security Council', 'DEL-USA-SC', 'Robert Wood', 'USA', 'Western Europe and Others', 'YES', 'GBR, JPN, DEU'),
(4, 'SC/RES/2730', 'Humanitarian Ceasefire', 'SC', 'Security Council', 'DEL-CHN-SC', 'Geng Shuang', 'CHN', 'Asia-Pacific', 'ABSTAIN', 'GBR, JPN, DEU'),
(4, 'SC/RES/2730', 'Humanitarian Ceasefire', 'SC', 'Security Council', 'DEL-FRA-SC', 'Nathalie Broadhurst', 'FRA', 'Western Europe and Others', 'YES', 'GBR, JPN, DEU');

SELECT * FROM UN_Proceedings_UNF;
```

**Output:**

```sql
+-----------+---------------+-----------------------------+------------+------------------+---------------+-------------------------+------------+---------------------------+------------+---------------+
| matter_id | matter_number | title                       | organ_code | organ_name       | delegate_code | delegate_name           | state_code | state_region              | vote_value | co_sponsors   |
+-----------+---------------+-----------------------------+------------+------------------+---------------+-------------------------+------------+---------------------------+------------+---------------+
|         1 | GA/RES/79/001 | Climate Action Acceleration | GA         | General Assembly | DEL-USA-GA    | Linda Thomas-Greenfield | USA        | Western Europe and Others | YES        | FRA, GBR, BRA |
|         1 | GA/RES/79/001 | Climate Action Acceleration | GA         | General Assembly | DEL-CHN-GA    | Fu Cong                 | CHN        | Asia-Pacific              | YES        | FRA, GBR, BRA |
|         1 | GA/RES/79/001 | Climate Action Acceleration | GA         | General Assembly | DEL-RUS-GA    | Vassily Nebenzia        | RUS        | Eastern Europe            | ABSTAIN    | FRA, GBR, BRA |
|         4 | SC/RES/2730   | Humanitarian Ceasefire      | SC         | Security Council | DEL-USA-SC    | Robert Wood             | USA        | Western Europe and Others | YES        | GBR, JPN, DEU |
|         4 | SC/RES/2730   | Humanitarian Ceasefire      | SC         | Security Council | DEL-CHN-SC    | Geng Shuang             | CHN        | Asia-Pacific              | ABSTAIN    | GBR, JPN, DEU |
|         4 | SC/RES/2730   | Humanitarian Ceasefire      | SC         | Security Council | DEL-FRA-SC    | Nathalie Broadhurst     | FRA        | Western Europe and Others | YES        | GBR, JPN, DEU |
+-----------+---------------+-----------------------------+------------+------------------+---------------+-------------------------+------------+---------------------------+------------+---------------+
```

**Pitfalls (Anomalies) in this structure:**

**1. Insertion Anomaly**

- **Problem:** We cannot meaningfully add a new delegate profile to the system unless they actively vote on a matter. For example, the United Kingdom's delegate `Barbara Woodward (DEL-GBR-GA)` can only be inserted by leaving `matter_id`, `vote_value`, and `co_sponsors` as `NULL` — because there is no independent `delegate` table to store her profile separately. The result is a broken, incomplete row that violates entity integrity.
- **Impact:** The UN Secretariat is unable to pre-register newly credentialed delegates ahead of a General Assembly session without injecting NULL-filled, semantically meaningless rows into the database. Operational readiness is compromised because delegate profiles, credential verification, and state assignments can only exist if tied to a voting record. This violates real-world UN procedure where delegates are accredited months before any vote occurs.

**2. Update Anomaly**

- **Problem:** If the `organ_name` for organ code `'GA'` changes (e.g., renamed to `'UN General Assembly'`), we must manually update every single row where a delegate voted on a GA matter. In our 6-row sample, the name `General Assembly` appears in 3 separate rows. Missing even one update creates contradictory data — one row says `'UN General Assembly'` while another still says `'General Assembly'` for the same organ code `'GA'`.
- **Impact:** Data inconsistency propagates silently across the database. Reports generated from this table would show conflicting organ names for the same organ code, undermining the credibility of official UN records. In a production system with thousands of votes, locating and correcting every affected row becomes practically impossible, leading to permanent data corruption.

**3. Deletion Anomaly**

- **Problem:** If we delete all records of Matter 4 (`SC/RES/2730 — Humanitarian Ceasefire`), we do not just lose the voting record — we permanently lose the fact that `'SC'` stands for `'Security Council'`, and we lose the entire delegate profiles of `Nathalie Broadhurst (FRA)`, `Geng Shuang (CHN)`, and `Robert Wood (USA)` from the Security Council, because their existence in the system depends entirely on their participation in that specific matter.
- **Impact:** Legitimate organizational data (organ definitions, delegate credentials) is destroyed as a side effect of removing a single procedural record. The UN would lose institutional knowledge: the Security Council's name mapping disappears, and three accredited diplomats are erased from the system simply because one resolution was archived. This makes historical auditing and accountability impossible.

#### 4.1.1 Demonstrating Anomalies in CMD SQL

To safely demonstrate these anomalies in your terminal without corrupting the actual `un_workflow_db` core tables, copy and paste the following sequential block into your `mysql>` prompt.

It uses a **Fixation Command** (`DROP TABLE IF EXISTS`) at the beginning and end, guaranteeing an isolated, temporary environment.

**SQL Statement (Setup & Anomalies):**

```sql
-- Fixation command (Clean up before)
DROP TABLE IF EXISTS UN_Anomaly_Demo;

-- 1. Create the isolated anomaly demo table
CREATE TABLE UN_Anomaly_Demo (
    matter_id INT, matter_number VARCHAR(20), title VARCHAR(100), organ_code VARCHAR(10), organ_name VARCHAR(50),
    delegate_code VARCHAR(20), delegate_name VARCHAR(50), state_code VARCHAR(3), state_region VARCHAR(50),
    vote_value VARCHAR(10), co_sponsors VARCHAR(100)
);

-- 2. Insert the mock data (as seen in the table above)
INSERT INTO UN_Anomaly_Demo VALUES
(1, 'GA/RES/79/001', 'Climate Action Acceleration', 'GA', 'General Assembly', 'DEL-USA-GA', 'Linda Thomas-Greenfield', 'USA', 'Western Europe and Others', 'YES', 'FRA, GBR, BRA'),
(1, 'GA/RES/79/001', 'Climate Action Acceleration', 'GA', 'General Assembly', 'DEL-CHN-GA', 'Fu Cong', 'CHN', 'Asia-Pacific', 'YES', 'FRA, GBR, BRA'),
(1, 'GA/RES/79/001', 'Climate Action Acceleration', 'GA', 'General Assembly', 'DEL-RUS-GA', 'Vassily Nebenzia', 'RUS', 'Eastern Europe', 'ABSTAIN', 'FRA, GBR, BRA'),
(4, 'SC/RES/2730', 'Humanitarian Ceasefire', 'SC', 'Security Council', 'DEL-USA-SC', 'Robert Wood', 'USA', 'Western Europe and Others', 'YES', 'GBR, JPN, DEU'),
(4, 'SC/RES/2730', 'Humanitarian Ceasefire', 'SC', 'Security Council', 'DEL-CHN-SC', 'Geng Shuang', 'CHN', 'Asia-Pacific', 'ABSTAIN', 'GBR, JPN, DEU'),
(4, 'SC/RES/2730', 'Humanitarian Ceasefire', 'SC', 'Security Council', 'DEL-FRA-SC', 'Nathalie Broadhurst', 'FRA', 'Western Europe and Others', 'YES', 'GBR, JPN, DEU');

-- 3. UPDATE ANOMALY DEMONSTRATION
-- Attempting to rename 'General Assembly' to 'UN General Assembly' but missing rows creates data inconsistency!
UPDATE UN_Anomaly_Demo SET organ_name = 'UN General Assembly' WHERE delegate_code = 'DEL-USA-GA';
SELECT matter_id, organ_code, organ_name, delegate_code FROM UN_Anomaly_Demo WHERE organ_code = 'GA';

-- 4. DELETE ANOMALY DEMONSTRATION
-- Deleting Matter 4 entirely erases all record of France's delegate (Nathalie Broadhurst) from the system!
DELETE FROM UN_Anomaly_Demo WHERE matter_id = 4;
SELECT delegate_name, state_code FROM UN_Anomaly_Demo WHERE state_code = 'FRA';

-- 5. INSERT ANOMALY DEMONSTRATION
-- Attempting to add a UK Delegate without an active matter forces us to use NULL values, breaking entity integrity.
INSERT INTO UN_Anomaly_Demo (delegate_code, delegate_name, state_code, state_region) 
VALUES ('DEL-GBR-GA', 'Barbara Woodward', 'GBR', 'Western Europe and Others');
SELECT * FROM UN_Anomaly_Demo WHERE delegate_code = 'DEL-GBR-GA';

-- Fixation command (Clean up after execution)
DROP TABLE IF EXISTS UN_Anomaly_Demo;
```

**Output Observations:**

1. **Update Anomaly Output:** You will see rows for `GA` returning conflicting names (`UN General Assembly` for the USA row, but `General Assembly` for CHN and RUS rows).
2. **Delete Anomaly Output:** The query for France delegates will return an **empty set**, proving that Nathalie Broadhurst's entire profile is permanently lost because it only existed in matter 4.
3. **Insert Anomaly Output:** The query will return a row for `DEL-GBR-GA`, but columns like `matter_id`, `organ_code`, and `vote_value` will be filled with `NULL`, exposing a broken structure.

---

### 4.2 First Normal Form (1NF)

#### 4.2.1: Identify Dependency

**Rule:** A relation is in 1NF if it contains only atomic (indivisible) values, completely eliminating repeating groups or multi-valued attributes.

**Dependencies forming the anomaly:**
In our `UN_Proceedings_UNF` table, the `co_sponsors` column contains multiple values per cell (e.g., `"FRA, GBR, BRA"`). Additionally, the Functional Dependencies (FDs) present are:

- `matter_id → {matter_number, title, organ_code, organ_name, co_sponsors}`
- `delegate_code → {delegate_name, state_code, state_region}`
- `{matter_id, delegate_code} → {vote_value}`

Because `co_sponsors` is multi-valued, there is no true single Primary Key for the raw relation yet.

**Before 1NF (the UNF table from Section 4.1):**

Refer to the `UN_Proceedings_UNF` table above. The problematic column is highlighted below:

```sql
-- The 'co_sponsors' column contains a REPEATING GROUP (violates 1NF)
SELECT matter_id, delegate_code, co_sponsors FROM UN_Proceedings_UNF;
```

```sql
+-----------+---------------+-------------------------------+
| matter_id | delegate_code | co_sponsors ← MULTI-VALUED   |
+-----------+---------------+-------------------------------+
|         1 | DEL-USA-GA    | FRA, GBR, BRA                 |
|         1 | DEL-CHN-GA    | FRA, GBR, BRA                 |
|         1 | DEL-RUS-GA    | FRA, GBR, BRA                 |
|         4 | DEL-USA-SC    | GBR, JPN, DEU                 |
|         4 | DEL-CHN-SC    | GBR, JPN, DEU                 |
|         4 | DEL-FRA-SC    | GBR, JPN, DEU                 |
+-----------+---------------+-------------------------------+
```

Each cell in `co_sponsors` holds 3 comma-separated state codes — a clear repeating group that must be atomized.

#### 4.2.2: Apply Normalization to 1NF

**Action:** Explode the comma-separated `co_sponsors` column into distinct atomic rows with one `co_sponsor_code` per row, establishing a composite primary key of `(matter_id, delegate_code, co_sponsor_code)`.

**After 1NF (Table: `UN_Proceedings_1NF`):**

**SQL Statement:**

```sql
-- Atomize the co_sponsors repeating group into individual rows
DROP TABLE IF EXISTS UN_Proceedings_1NF;

CREATE TABLE UN_Proceedings_1NF (
    matter_id INT, matter_number VARCHAR(20), title VARCHAR(100), organ_code VARCHAR(10), organ_name VARCHAR(50),
    delegate_code VARCHAR(20), delegate_name VARCHAR(50), state_code VARCHAR(3), state_region VARCHAR(50),
    vote_value VARCHAR(10), co_sponsor_code VARCHAR(3)
);

INSERT INTO UN_Proceedings_1NF VALUES
(1,'GA/RES/79/001','Climate Action Acceleration','GA','General Assembly','DEL-USA-GA','Linda Thomas-Greenfield','USA','Western Europe and Others','YES','BRA'),
(1,'GA/RES/79/001','Climate Action Acceleration','GA','General Assembly','DEL-USA-GA','Linda Thomas-Greenfield','USA','Western Europe and Others','YES','FRA'),
(1,'GA/RES/79/001','Climate Action Acceleration','GA','General Assembly','DEL-USA-GA','Linda Thomas-Greenfield','USA','Western Europe and Others','YES','GBR'),
(1,'GA/RES/79/001','Climate Action Acceleration','GA','General Assembly','DEL-CHN-GA','Fu Cong','CHN','Asia-Pacific','YES','BRA'),
(1,'GA/RES/79/001','Climate Action Acceleration','GA','General Assembly','DEL-CHN-GA','Fu Cong','CHN','Asia-Pacific','YES','FRA'),
(1,'GA/RES/79/001','Climate Action Acceleration','GA','General Assembly','DEL-CHN-GA','Fu Cong','CHN','Asia-Pacific','YES','GBR'),
(1,'GA/RES/79/001','Climate Action Acceleration','GA','General Assembly','DEL-RUS-GA','Vassily Nebenzia','RUS','Eastern Europe','ABSTAIN','BRA'),
(1,'GA/RES/79/001','Climate Action Acceleration','GA','General Assembly','DEL-RUS-GA','Vassily Nebenzia','RUS','Eastern Europe','ABSTAIN','FRA'),
(1,'GA/RES/79/001','Climate Action Acceleration','GA','General Assembly','DEL-RUS-GA','Vassily Nebenzia','RUS','Eastern Europe','ABSTAIN','GBR'),
(4,'SC/RES/2730','Humanitarian Ceasefire','SC','Security Council','DEL-USA-SC','Robert Wood','USA','Western Europe and Others','YES','DEU'),
(4,'SC/RES/2730','Humanitarian Ceasefire','SC','Security Council','DEL-USA-SC','Robert Wood','USA','Western Europe and Others','YES','GBR'),
(4,'SC/RES/2730','Humanitarian Ceasefire','SC','Security Council','DEL-USA-SC','Robert Wood','USA','Western Europe and Others','YES','JPN'),
(4,'SC/RES/2730','Humanitarian Ceasefire','SC','Security Council','DEL-CHN-SC','Geng Shuang','CHN','Asia-Pacific','ABSTAIN','DEU'),
(4,'SC/RES/2730','Humanitarian Ceasefire','SC','Security Council','DEL-CHN-SC','Geng Shuang','CHN','Asia-Pacific','ABSTAIN','GBR'),
(4,'SC/RES/2730','Humanitarian Ceasefire','SC','Security Council','DEL-CHN-SC','Geng Shuang','CHN','Asia-Pacific','ABSTAIN','JPN'),
(4,'SC/RES/2730','Humanitarian Ceasefire','SC','Security Council','DEL-FRA-SC','Nathalie Broadhurst','FRA','Western Europe and Others','YES','DEU'),
(4,'SC/RES/2730','Humanitarian Ceasefire','SC','Security Council','DEL-FRA-SC','Nathalie Broadhurst','FRA','Western Europe and Others','YES','GBR'),
(4,'SC/RES/2730','Humanitarian Ceasefire','SC','Security Council','DEL-FRA-SC','Nathalie Broadhurst','FRA','Western Europe and Others','YES','JPN');

SELECT * FROM UN_Proceedings_1NF LIMIT 6;
```

**Output:**

```sql
+-----------+---------------+-----------------------------+------------+------------------+---------------+-------------------------+------------+---------------------------+------------+-----------------+
| matter_id | matter_number | title                       | organ_code | organ_name       | delegate_code | delegate_name           | state_code | state_region              | vote_value | co_sponsor_code |
+-----------+---------------+-----------------------------+------------+------------------+---------------+-------------------------+------------+---------------------------+------------+-----------------+
|         1 | GA/RES/79/001 | Climate Action Acceleration | GA         | General Assembly | DEL-USA-GA    | Linda Thomas-Greenfield | USA        | Western Europe and Others | YES        | BRA             |
|         1 | GA/RES/79/001 | Climate Action Acceleration | GA         | General Assembly | DEL-USA-GA    | Linda Thomas-Greenfield | USA        | Western Europe and Others | YES        | FRA             |
|         1 | GA/RES/79/001 | Climate Action Acceleration | GA         | General Assembly | DEL-USA-GA    | Linda Thomas-Greenfield | USA        | Western Europe and Others | YES        | GBR             |
|         1 | GA/RES/79/001 | Climate Action Acceleration | GA         | General Assembly | DEL-CHN-GA    | Fu Cong                 | CHN        | Asia-Pacific              | YES        | BRA             |
|         1 | GA/RES/79/001 | Climate Action Acceleration | GA         | General Assembly | DEL-CHN-GA    | Fu Cong                 | CHN        | Asia-Pacific              | YES        | FRA             |
|         1 | GA/RES/79/001 | Climate Action Acceleration | GA         | General Assembly | DEL-CHN-GA    | Fu Cong                 | CHN        | Asia-Pacific              | YES        | GBR             |
... (showing first 6 rows of 18 total rows in set)
+-----------+---------------+-----------------------------+------------+------------------+---------------+-------------------------+------------+---------------------------+------------+-----------------+
18 rows in set (0.01 sec)
```

*Note: The dataset exploded from 6 to 18 rows (6 delegates × 3 co-sponsors each) to maintain atomic values. The Primary Key is now `(matter_id, delegate_code, co_sponsor_code)`.*

---

### 4.3 Second Normal Form (2NF)

#### 4.3.1: Identify Dependency

**Rule:** A table is in 2NF if it is in 1NF **and** every non-key attribute is fully functionally dependent on the **entire** primary key. This means eliminating **partial dependencies**.

**Partial Dependencies in 1NF Table:**
With the composite Primary Key `(matter_id, delegate_code, co_sponsor_code)`:

- `matter_id → {matter_number, title, organ_code, organ_name}` (Depends only on part of the PK)
- `delegate_code → {delegate_name, state_code, state_region}` (Depends only on part of the PK)
- `{matter_id, delegate_code} → {vote_value}` (Depends on two parts of the PK, independent of co_sponsor_code)

These partial dependencies mean `title` and `delegate_name` repeat unnecessarily for every co-sponsor row.

**Before 2NF (the 1NF table from Section 4.2):**

Refer to the 1NF table above. With PK = `(matter_id, delegate_code, co_sponsor_code)`, partial dependencies are visible:

```sql
-- Columns that depend on ONLY PART of the PK (violates 2NF)
SELECT matter_id, delegate_code, co_sponsor_code,
       title,          -- depends ONLY on matter_id (partial)
       delegate_name,  -- depends ONLY on delegate_code (partial)
       vote_value      -- depends on {matter_id, delegate_code} not co_sponsor_code (partial)
FROM UN_Proceedings_1NF WHERE delegate_code = 'DEL-USA-GA';
```

```sql
+-----------+---------------+-----------------+-----------------------------+-------------------------+------------+
| matter_id | delegate_code | co_sponsor_code | title ← PARTIAL             | delegate_name ← PARTIAL | vote_value |
+-----------+---------------+-----------------+-----------------------------+-------------------------+------------+
|         1 | DEL-USA-GA    | BRA             | Climate Action Acceleration | Linda Thomas-Greenfield | YES        |
|         1 | DEL-USA-GA    | FRA             | Climate Action Acceleration | Linda Thomas-Greenfield | YES        |
|         1 | DEL-USA-GA    | GBR             | Climate Action Acceleration | Linda Thomas-Greenfield | YES        |
+-----------+---------------+-----------------+-----------------------------+-------------------------+------------+
```

Notice: `title` and `delegate_name` are identical across all 3 rows — they depend only on `matter_id` and `delegate_code` respectively, not on `co_sponsor_code`. This is the partial dependency that 2NF eliminates.

#### 4.3.2: Apply Normalization to 2NF

**Action:** Decompose the 1NF table into four tables based on the precise partial dependencies, projecting the identical data.

**After 2NF — Decomposed Tables:**

**1. `Matter_2NF` (depends on `matter_id`)**

**SQL Statement:**

```sql
SELECT matter_id, matter_number, title, organ_code, organ_name 
FROM matter m JOIN un_organ o ON m.organ_id = o.organ_id 
WHERE matter_id IN (1, 4);
```

**Output:**

```sql
+-----------+---------------+-----------------------------+------------+------------------+
| matter_id | matter_number | title                       | organ_code | organ_name       |
+-----------+---------------+-----------------------------+------------+------------------+
|         1 | GA/RES/79/001 | Climate Action Acceleration | GA         | General Assembly |
|         4 | SC/RES/2730   | Humanitarian Ceasefire      | SC         | Security Council |
+-----------+---------------+-----------------------------+------------+------------------+
```

**2. `Delegate_2NF` (depends on `delegate_code`)**

**SQL Statement:**

```sql
SELECT d.delegate_code, CONCAT(d.first_name, ' ', d.last_name) AS delegate_name, ms.state_code, ms.region AS state_region 
FROM delegate d JOIN member_state ms ON d.state_id = ms.state_id 
WHERE d.delegate_id IN (1, 2, 3, 16, 17, 20);
```

**Output:**

```sql
+---------------+-------------------------+------------+---------------------------+
| delegate_code | delegate_name           | state_code | state_region              |
+---------------+-------------------------+------------+---------------------------+
| DEL-USA-GA    | Linda Thomas-Greenfield | USA        | Western Europe and Others |
| DEL-CHN-GA    | Fu Cong                 | CHN        | Asia-Pacific              |
| DEL-RUS-GA    | Vassily Nebenzia        | RUS        | Eastern Europe            |
| DEL-USA-SC    | Robert Wood             | USA        | Western Europe and Others |
| DEL-CHN-SC    | Geng Shuang             | CHN        | Asia-Pacific              |
| DEL-FRA-SC    | Nathalie Broadhurst     | FRA        | Western Europe and Others |
+---------------+-------------------------+------------+---------------------------+
```

**3. `Vote_2NF` (depends on `matter_id, delegate_code`)**

**SQL Statement:**

```sql
SELECT matter_id, delegate_code, vote_value 
FROM vote v JOIN delegate d ON v.delegate_id = d.delegate_id 
WHERE matter_id IN (1, 4) AND v.delegate_id IN (1, 2, 3, 16, 17, 20);
```

**Output:**

```sql
+-----------+---------------+------------+
| matter_id | delegate_code | vote_value |
+-----------+---------------+------------+
|         1 | DEL-USA-GA    | YES        |
|         1 | DEL-CHN-GA    | YES        |
|         1 | DEL-RUS-GA    | ABSTAIN    |
|         4 | DEL-USA-SC    | YES        |
|         4 | DEL-CHN-SC    | ABSTAIN    |
|         4 | DEL-FRA-SC    | YES        |
+-----------+---------------+------------+
```

**4. `Matter_CoSponsor_2NF` (depends on `matter_id`)**

**SQL Statement:**

```sql
SELECT DISTINCT matter_id, co_sponsor_code FROM UN_Proceedings_1NF ORDER BY matter_id, co_sponsor_code;
```

**Output:**

```sql
+-----------+-----------------+
| matter_id | co_sponsor_code |
+-----------+-----------------+
|         1 | BRA             |
|         1 | FRA             |
|         1 | GBR             |
|         4 | DEU             |
|         4 | GBR             |
|         4 | JPN             |
+-----------+-----------------+
```

---

### 4.4 Third Normal Form (3NF)

#### 4.4.1: Identify Dependency

**Rule:** A table is in 3NF if it is in 2NF **and** every non-key attribute is non-transitively dependent on the primary key. This means eliminating **transitive dependencies** (when a non-key attribute depends on another non-key attribute).

**Transitive Dependencies in 2NF Tables:**

- In `Matter_2NF`: `matter_id → organ_code → organ_name`. The name of the organ depends strictly on the `organ_code`, making it a transitive dependency.
- In `Delegate_2NF`: `delegate_code → state_code → state_region`. The region of the state depends strictly on the `state_code`, creating another transitive dependency.

Notice that in `Delegate_2NF`, "Western Europe and Others" is repeated twice because it is tied to "USA".

**Before 3NF (the 2NF tables from Section 4.3):**

The transitive dependencies are visible within the 2NF output tables:

```sql
-- Matter_2NF: organ_name depends on organ_code, NOT directly on matter_id
SELECT matter_id, organ_code, organ_name FROM matter m
JOIN un_organ o ON m.organ_id = o.organ_id WHERE matter_id IN (1, 4);
```

```sql
+-----------+------------+------------------+
| matter_id | organ_code | organ_name       |
+-----------+------------+--------+---------+
|         1 | GA         | General Assembly |  ← organ_name depends on organ_code, NOT matter_id
|         4 | SC         | Security Council |  ← This is a TRANSITIVE dependency
+-----------+------------+------------------+
```

```sql
-- Delegate_2NF: state_region depends on state_code, NOT directly on delegate_code
SELECT delegate_code, state_code, state_region FROM Delegate_2NF;
```

```sql
+---------------+------------+---------------------------+
| delegate_code | state_code | state_region              |
+---------------+------------+---------------------------+
| DEL-USA-GA    | USA        | Western Europe and Others |  ← state_region depends on state_code
| DEL-USA-SC    | USA        | Western Europe and Others |  ← SAME region repeated (transitive)
| DEL-FRA-SC    | FRA        | Western Europe and Others |  ← SAME region for different state_code
+---------------+------------+---------------------------+
```

The `organ_name` is fully determined by `organ_code` (not by `matter_id`), and `state_region` is fully determined by `state_code` (not by `delegate_code`). These transitive chains must be broken.

#### 4.4.2: Apply Normalization to 3NF

**Action:** Remove the transitively dependent attributes (`organ_name`, `state_region`) into their own standalone lookup tables.

**After 3NF — Final Decomposed Reference Tables:**

**1. `Matter`**

**SQL Statement:**

```sql
SELECT matter_id, matter_number, title, organ_code 
FROM matter m JOIN un_organ o ON m.organ_id = o.organ_id WHERE matter_id IN (1, 4);
```

**Output:**

```sql
+-----------+---------------+-----------------------------+------------+
| matter_id | matter_number | title                       | organ_code |
+-----------+---------------+-----------------------------+------------+
|         1 | GA/RES/79/001 | Climate Action Acceleration | GA         |
|         4 | SC/RES/2730   | Humanitarian Ceasefire      | SC         |
+-----------+---------------+-----------------------------+------------+
```

**2. `un_organ` (Extracted)**

**SQL Statement:**

```sql
SELECT organ_code, organ_name FROM un_organ WHERE organ_code IN ('GA', 'SC');
```

**Output:**

```sql
+------------+------------------+
| organ_code | organ_name       |
+------------+------------------+
| GA         | General Assembly |
| SC         | Security Council |
+------------+------------------+
```

**3. `delegate`**

**SQL Statement:**

```sql
SELECT delegate_code, CONCAT(first_name, ' ', last_name) AS delegate_name, state_code 
FROM delegate d JOIN member_state ms ON d.state_id = ms.state_id 
WHERE delegate_id IN (1, 2, 3, 16, 17, 20);
```

**Output:**

```sql
+---------------+-------------------------+------------+
| delegate_code | delegate_name           | state_code |
+---------------+-------------------------+------------+
| DEL-USA-GA    | Linda Thomas-Greenfield | USA        |
| DEL-CHN-GA    | Fu Cong                 | CHN        |
| DEL-RUS-GA    | Vassily Nebenzia        | RUS        |
| DEL-USA-SC    | Robert Wood             | USA        |
| DEL-CHN-SC    | Geng Shuang             | CHN        |
| DEL-FRA-SC    | Nathalie Broadhurst     | FRA        |
+---------------+-------------------------+------------+
```

**4. `member_state` (Extracted)**

**SQL Statement:**

```sql
SELECT state_code, region AS state_region FROM member_state WHERE state_code IN ('USA', 'CHN', 'RUS', 'FRA');
```

**Output:**

```sql
+------------+---------------------------+
| state_code | state_region              |
+------------+---------------------------+
| USA        | Western Europe and Others |
| CHN        | Asia-Pacific              |
| RUS        | Eastern Europe            |
| FRA        | Western Europe and Others |
+------------+---------------------------+
```

*(The strict 3NF decomposition eliminates all redundancy, completing the primary data structure of our UN Database.)*

---

### 4.5 Boyce-Codd Normal Form (BCNF)

*(To demonstrate higher normal forms, we transition to applying UN Database rules to complex sub-relations, moving beyond standard 3NF tables).*

#### 4.5.1: Identify Dependency

**Rule:** A relation is in BCNF if and only if for every non-trivial functional dependency `X → Y`, the determinant `X` is a **superkey**. BCNF catches an anomaly 3NF misses: when a part of a composite primary key is dependent on a non-key attribute.

**The UN Scenerio:** Let's look at a hypothetical integrated voting tracking table: `Session_Vote`.
A state votes on a matter through exactly one delegate. The Candidate Keys for tracking this vote are `(matter_id, state_id)` or `(matter_id, delegate_id)`.

**Before BCNF (`Session_Vote` Relation):**

**SQL Statement:**

```sql
SELECT v.matter_id, ms.state_id, ms.state_code, d.delegate_id, d.delegate_code, v.vote_value
FROM vote v
JOIN delegate d ON v.delegate_id = d.delegate_id
JOIN member_state ms ON v.state_id = ms.state_id
WHERE v.matter_id = 1 AND d.delegate_id IN (1, 2, 3)
ORDER BY v.matter_id, ms.state_id;
```

**Output:**

```sql
+-----------+----------+------------+-------------+---------------+------------+
| matter_id | state_id | state_code | delegate_id | delegate_code | vote_value |
+-----------+----------+------------+-------------+---------------+------------+
|         1 |        1 | USA        |           1 | DEL-USA-GA    | YES        |
|         1 |        2 | CHN        |           2 | DEL-CHN-GA    | YES        |
|         1 |        3 | RUS        |           3 | DEL-RUS-GA    | ABSTAIN    |
+-----------+----------+------------+-------------+---------------+------------+
```

**Dependency Violation:** In the UN, a specific delegate represents exactly one state (`delegate_id → state_id`). Even though `delegate_id` is a determinant, it is **not a superkey** for the entire table (as a delegate votes on many matters). Thus, `delegate_id → state_id` violates BCNF.

#### 4.5.2: Apply Normalization to BCNF

**Action:** Extract the determinant (`delegate_id`) and its dependent (`state_id`) into a dedicated `delegate` table, removing `state_id` from the `vote` table.

**After BCNF — Validating our Actual Database Design:**
This is exactly why our final database schema splits the relationship:

**Table 1: `delegate` (Maps delegate to state)**

**SQL Statement:**

```sql
SELECT delegate_id, state_id FROM delegate WHERE delegate_id IN (1, 2, 3);
```

**Output:**

```sql
+-------------+------------+
| delegate_id | state_id   |
+-------------+------------+
|           1 |        1   |
|           2 |        2   |
|           3 |        3   |
+-------------+------------+
```

**Table 2: `vote` (Tracks matter and delegate)**

**SQL Statement:**

```sql
SELECT matter_id, delegate_id, vote_value FROM vote WHERE matter_id = 1 AND delegate_id IN (1, 2, 3);
```

**Output:**

```sql
+-----------+-------------+------------+
| matter_id | delegate_id | vote_value |
+-----------+-------------+------------+
|         1 |           1 | YES        |
|         1 |           2 | YES        |
|         1 |           3 | ABSTAIN    |
+-----------+-------------+------------+
```

---

### 4.6 Fourth Normal Form (4NF)

#### 4.6.1: Identify Dependency

**Rule:** A relation is in 4NF if it is in BCNF and contains no **independent multi-valued dependencies (MVDs)**. An MVD (`A →→ B`) occurs when an attribute maps to an independent set of values, forcing a Cartesian product.

**The UN Scenario:** What if we tried to track the co-sponsors of a matter alongside the delegates assigned to it in a single unnormalized view?
A matter has multiple co-sponsors (`matter_id →→ co_sponsor_code`).
A matter is voted on by multiple delegates (`matter_id →→ delegate_code`).
Because delegates and co-sponsors are completely independent facts about the matter, forcing them into one table creates redundancy.

**Before 4NF (`Matter_Tracking`):**

**SQL Statement:**

```sql
-- Demonstrating the Cartesian product of independent MVDs
SELECT a.matter_id, a.delegate_code, b.co_sponsor_code
FROM (
  SELECT DISTINCT matter_id, delegate_code FROM UN_Proceedings_1NF
  WHERE matter_id = 1 AND delegate_code IN ('DEL-USA-GA', 'DEL-CHN-GA')
) a
JOIN (
  SELECT DISTINCT matter_id, co_sponsor_code FROM UN_Proceedings_1NF
  WHERE matter_id = 1
) b ON a.matter_id = b.matter_id
ORDER BY a.delegate_code, b.co_sponsor_code;
```

**Output:**

```sql
+-----------+---------------+-----------------+
| matter_id | delegate_code | co_sponsor_code |
+-----------+---------------+-----------------+
|         1 | DEL-CHN-GA    | BRA             |
|         1 | DEL-CHN-GA    | FRA             |
|         1 | DEL-CHN-GA    | GBR             |
|         1 | DEL-USA-GA    | BRA             |
|         1 | DEL-USA-GA    | FRA             |
|         1 | DEL-USA-GA    | GBR             |
+-----------+---------------+-----------------+
```

*Notice the Cartesian product: (2 delegates × 3 co-sponsors = 6 rows). The independent variables are artificially crossing.*

#### 4.6.2: Apply Normalization to 4NF

**Action:** Divide the relation into two distinct tables sharing the primary key attribute `matter_id`.

**After 4NF (Removing the MVD product):**
In our final schema, these are strictly isolated to avoid the Cartesian explosion:

**1. `Matter_Delegate` (`vote` table):**

**SQL Statement:**

```sql
SELECT v.matter_id, d.delegate_code 
FROM vote v JOIN delegate d ON v.delegate_id = d.delegate_id 
WHERE v.matter_id IN (1, 4) AND d.delegate_id IN (1, 2, 3, 16, 17, 20);
```

**Output:**

```sql
+-----------+---------------+
| matter_id | delegate_code |
+-----------+---------------+
|         1 | DEL-USA-GA    |
|         1 | DEL-CHN-GA    |
|         1 | DEL-RUS-GA    |
|         4 | DEL-USA-SC    |
|         4 | DEL-CHN-SC    |
|         4 | DEL-FRA-SC    |
+-----------+---------------+
```

**2. `Matter_CoSponsor`:**

**SQL Statement:**

```sql
SELECT DISTINCT matter_id, co_sponsor_code FROM UN_Proceedings_1NF ORDER BY matter_id, co_sponsor_code;
```

**Output:**

```sql
+-----------+-----------------+
| matter_id | co_sponsor_code |
+-----------+-----------------+
|         1 | BRA             |
|         1 | FRA             |
|         1 | GBR             |
|         4 | DEU             |
|         4 | GBR             |
|         4 | JPN             |
+-----------+-----------------+
```

*(4NF achieved: No independent sets cross-pollinate within a single table).*

---

### 4.7 Fifth Normal Form (5NF)

#### 4.7.1: Identify Dependency

**Rule:** A relation is in 5NF (Project-Join Normal Form) if it is in 4NF and cannot be losslessly decomposed into three or more smaller tables. It specifically eliminates cyclical **Join Dependencies (JD)**.

**The UN Scenario:** The International Court of Justice (ICJ) ad-hoc judge rule creates a cyclical join dependency.
Consider the relationship: `(case_id, judge_id, state_id)`.

1. An ICJ Case involves Member States (`case_id ↔ state_id`).
2. An ICJ Judge holds a specific Nationality State (`judge_id ↔ state_id`).
3. An ICJ Judge sits on an ICJ Case Panel (`case_id ↔ judge_id`).

**The Rule:** If a Case involves State X, and a Judge from State X sits on the court, they *must* be assigned to that Case.
Because of this intrinsic triangle rule, you cannot decompose this into just two tables without losing information or creating false data upon a natural join.

**Before 5NF (The 3-way cyclical dependency table):**

**SQL Statement:**

```sql
SELECT cj.case_id, cj.judge_id, j.nationality_state_id AS state_id
FROM icj_case_judge cj
JOIN icj_judge j ON cj.judge_id = j.judge_id
WHERE cj.case_id = 1 AND cj.judge_id IN (1, 3);
```

**Output:**

```sql
+---------+----------+----------+
| case_id | judge_id | state_id |
+---------+----------+----------+
|       1 |        1 |       12 |
|       1 |        3 |       10 |
+---------+----------+----------+
```

#### 4.7.2: Apply Normalization to 5NF

**Action:** A true 5NF violation with a Join Dependency is perfectly resolved by decomposing it into exactly three distinct tables representing the binary linkages.

**After 5NF Decomposition in our Database:**
This is executed flawlessly in our schema bridging the ICJ tables:

**1. Case relates to Judge (`icj_case_judge` table):**

**SQL Statement:**

```sql
SELECT case_id, judge_id FROM icj_case_judge WHERE case_id = 1 AND judge_id IN (1, 3);
```

**Output:**

```sql
+---------+----------+
| case_id | judge_id |
+---------+----------+
|       1 |        1 |
|       1 |        3 |
+---------+----------+
```

**2. Case relates to State (State parties tracked implicitly against the case):**

**SQL Statement:**

```sql
SELECT cj.case_id, j.nationality_state_id AS state_id
FROM icj_case_judge cj
JOIN icj_judge j ON cj.judge_id = j.judge_id
WHERE cj.case_id = 1 AND cj.judge_id IN (1, 3);
```

**Output:**

```sql
+---------+----------+
| case_id | state_id |
+---------+----------+
|       1 |       12 |
|       1 |       10 |
+---------+----------+
```

**3. Judge relates to State (`icj_judge` nationality mapping):**

**SQL Statement:**

```sql
SELECT judge_id, nationality_state_id AS state_id FROM icj_judge WHERE judge_id IN (1, 3);
```

**Output:**

```sql
+----------+----------+
| judge_id | state_id |
+----------+----------+
|        1 |       12 |
|        3 |       10 |
+----------+----------+
```

*(5NF Achieved: Re-joining all three tables produces the exact original dataset with no spurious rows, perfectly modeling the ICJ cyclical logic).*

# CHAPTER 5

## IMPLEMENTATION OF CONCURRENCY CONTROL AND RECOVERY MECHANISMS

Database transactions ensure data integrity where multiple users (such as UN delegates and Secretariat officers) interact with the system simultaneously.

### 5.1 Introduction to Transactions

A transaction is a single logical unit of work that accesses and possibly modifies the contents of a database. In the UN database, assigning a judge, logging a vote, or moving a workflow stage to the next phase are all handled as transactions.

#### 5.1.1 Properties (ACID)

To ensure data integrity, UN transactions must satisfy the ACID properties:

- **Atomicity:** All operations within the transaction succeed, or all fail. Example: If a vote is recorded but the `matter_workflow` fails to update `stage_status` to 'COMPLETED', the entire vote is rolled back.
- **Consistency:** The transaction transforms the database from one valid state to another. Example: The `chk_submitter` constraint guarantees a matter always has exactly one valid submitter.
- **Isolation:** Concurrent transactions do not interfere with each other. Example: Two delegates voting on the same resolution at the exact same millisecond will not cause a race condition.
- **Durability:** Once a transaction commits, the changes persist permanently, even against system failures.

#### 5.1.2 States

A transaction goes through several states during its lifetime:

1. **Active:** The initial state; the transaction stays in this state while executing operations.
2. **Partially Committed:** After the final statement has been executed, but before the commit.
3. **Committed:** After successful completion. The database has permanently stored the updates.
4. **Failed:** If a check constraint is violated or a hardware failure occurs during the active state.
5. **Aborted:** After the transaction has been rolled back and the database is restored to its state prior to the start of the transaction.

### 5.2 Transaction Control Language (TCL)

TCL commands manage the changes made by DML statements and group them into logical transactions.

#### 5.2.1 Savepoint

`SAVEPOINT savepoint_name` temporarily marks a location within a transaction. It allows rolling back a portion of the transaction's changes without undoing the entire transaction.

#### 5.2.2 Commit

`COMMIT` makes all database changes made during the current transaction permanent and ends the transaction. It releases any database locks held by the transaction.

#### 5.2.3 Rollback

`ROLLBACK` undoes all data changes made during the current open transaction and releases any locks. `ROLLBACK TO savepoint_name` reverts changes only up to the specified savepoint.

---

### 5.3 Create 5 transactions for your project and execute

The following five transactions model critical workflow processes within the United Nations system utilizing TCL commands.

#### 5.3.1 Transaction 1: Submitting a General Assembly Resolution

**ACID Property Demonstrated: Atomicity** — The INSERT of the matter, its workflow initialization, stage completion, and advancement to INITIAL_REVIEW either ALL succeed together or NONE apply. If any step fails (e.g., a constraint violation on `matter_workflow`), the entire submission is rolled back, leaving no orphaned matter record without a workflow.

**Scenario:** A delegate submits a resolution and it immediately advances to the `INITIAL_REVIEW` stage.

```sql
START TRANSACTION;

-- Step 1: Insert the new matter to the database
INSERT INTO matter (matter_number, title, description, matter_type, organ_id, submitted_by_delegate_id, priority, status, submission_date)
VALUES ('GA/RES/80/001', 'Global Tech Access Initiative', 'Ensuring technology access for developing states', 'RESOLUTION', 1, 1, 'HIGH', 'SUBMITTED', CURDATE());

-- Capture the generated matter_id
SET @new_matter_id = LAST_INSERT_ID();

-- Step 2: Initialize its first workflow stage
INSERT INTO matter_workflow (matter_id, stage_number, stage_name, stage_status, started_at)
VALUES (@new_matter_id, 1, 'SUBMISSION', 'IN_PROGRESS', NOW());

SAVEPOINT after_submission;

-- Step 3: Automatically advance it to the next stage
UPDATE matter_workflow SET stage_status = 'COMPLETED', completed_at = NOW()
WHERE matter_id = @new_matter_id AND stage_number = 1;

INSERT INTO matter_workflow (matter_id, stage_number, stage_name, stage_status, started_at)
VALUES (@new_matter_id, 2, 'INITIAL_REVIEW', 'IN_PROGRESS', NOW());

COMMIT;

-- Verification: Confirm the matter and its workflow stages were created
SELECT m.matter_id, m.matter_number, m.title, m.status, mw.stage_number, mw.stage_name, mw.stage_status
FROM matter m JOIN matter_workflow mw ON m.matter_id = mw.matter_id
WHERE m.matter_number = 'GA/RES/80/001'
ORDER BY mw.stage_number;
```

**Output:**

```sql
Query OK, 1 row affected (0.01 sec)  -- INSERT matter
Query OK, 1 row affected (0.00 sec)  -- INSERT workflow stage 1
Query OK, 1 row affected (0.00 sec)  -- UPDATE stage 1 to COMPLETED
Query OK, 1 row affected (0.00 sec)  -- INSERT workflow stage 2
Query OK, 0 rows affected (0.00 sec)  -- COMMIT

+-----------+---------------+-------------------------------+-----------+--------------+----------------+--------------+
| matter_id | matter_number | title                         | status    | stage_number | stage_name     | stage_status |
+-----------+---------------+-------------------------------+-----------+--------------+----------------+--------------+
|        11 | GA/RES/80/001 | Global Tech Access Initiative | SUBMITTED |            1 | SUBMISSION     | COMPLETED    |
|        11 | GA/RES/80/001 | Global Tech Access Initiative | SUBMITTED |            2 | INITIAL_REVIEW | IN_PROGRESS  |
+-----------+---------------+-------------------------------+-----------+--------------+----------------+--------------+
2 rows in set (0.00 sec)
```

*The transaction atomically created the matter, initialized its first workflow stage, completed it, and advanced to INITIAL_REVIEW — all as one indivisible unit.*

#### 5.3.2 Transaction 2: Security Council Veto Handling (Rollback)

**ACID Property Demonstrated: Consistency** — The database transitions from one valid state (a pending resolution with an active committee review) to another valid state (a rejected resolution with a cancelled workflow stage). The `ROLLBACK TO` savepoint ensures the premature workflow advance is undone before the rejection is applied, so the database never enters an inconsistent state where a matter is simultaneously "IN_PROGRESS" and "REJECTED".

**Scenario:** A permanent member casts a 'NO' vote on a pending Security Council resolution (SC/RES/2731), which constitutes a veto. The entire matter must immediately be rejected, and the review stage aborted.

```sql
START TRANSACTION;

-- Step 1: A P5 delegate casts a 'NO' vote on a pending SC resolution
INSERT INTO vote (matter_id, state_id, delegate_id, vote_value)
VALUES (5, 3, 18, 'NO');  -- Russia votes NO on SC/RES/2731

SAVEPOINT veto_detected;

-- Step 2: The system attempts to advance the workflow stage
UPDATE matter_workflow SET stage_status = 'IN_PROGRESS' WHERE matter_id = 5 AND stage_name = 'COMMITTEE_REVIEW';

-- Step 3: Trigger check identifies the veto explicitly. The voting process must be halted.
ROLLBACK TO veto_detected;

-- Step 4: Instantly reject the resolution due to P5 veto
UPDATE matter SET status = 'REJECTED', actual_completion_date = CURDATE() WHERE matter_id = 5;
UPDATE matter_workflow SET stage_status = 'CANCELLED', completed_at = NOW() WHERE matter_id = 5 AND stage_name = 'COMMITTEE_REVIEW';

COMMIT;

-- Verification: Confirm the matter was rejected and the workflow stage was cancelled
SELECT m.matter_id, m.matter_number, m.status, mw.stage_name, mw.stage_status
FROM matter m JOIN matter_workflow mw ON m.matter_id = mw.matter_id
WHERE m.matter_id = 5 AND mw.stage_name = 'COMMITTEE_REVIEW';
```

**Output:**

```sql
Query OK, 1 row affected (0.01 sec)  -- INSERT vote (NO)
Query OK, 1 row affected (0.00 sec)  -- UPDATE workflow (attempted advance)
Query OK, 0 rows affected (0.00 sec)  -- ROLLBACK TO veto_detected
Query OK, 1 row affected (0.00 sec)  -- UPDATE matter status to REJECTED
Query OK, 1 row affected (0.00 sec)  -- UPDATE workflow to CANCELLED
Query OK, 0 rows affected (0.00 sec)  -- COMMIT

+-----------+---------------+----------+------------------+--------------+
| matter_id | matter_number | status   | stage_name       | stage_status |
+-----------+---------------+----------+------------------+--------------+
|         5 | SC/RES/2731   | REJECTED | COMMITTEE_REVIEW | CANCELLED    |
+-----------+---------------+----------+------------------+--------------+
1 row in set (0.00 sec)
```

*The SAVEPOINT allowed the system to undo the premature workflow advance while still keeping the NO vote record intact. The resolution was then properly rejected.*

#### 5.3.3 Transaction 3: Ad-Hoc ICJ Judge Appointment

**ACID Property Demonstrated: Isolation** — The first transaction attempts to insert an invalid judge reference and FAILS. Because of Isolation, this failed transaction does not leave any partial artifacts visible to other concurrent sessions — no phantom `icj_case_judge` row with judge_id 999 is ever exposed to another user querying the system. The ROLLBACK ensures the failed attempt is completely invisible to the outside world. The second transaction then succeeds independently, creating both the judge and the case assignment atomically.

**Scenario:** A state requests an ad-hoc judge. If the judge isn't registered, they are added to the system, then appointed to the case.

```sql
START TRANSACTION;

-- Step 1: Attempt to assign an existing judge
INSERT INTO icj_case_judge (case_id, judge_id, is_ad_hoc, appointed_by_state_id)
VALUES (1, 999, TRUE, 7); -- 999 does not exist

-- Error occurs (Foreign Key violation). Transaction is in a Failed state.
ROLLBACK;

-- Step 2: Restart transaction with proper sequence
START TRANSACTION;
INSERT INTO icj_judge (judge_code, first_name, last_name, nationality_state_id, appointment_date, term_end_date)
VALUES ('ICJ-J-AH1', 'Takeshi', 'Yamamoto', 7, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 3 YEAR));

SET @new_judge_id = LAST_INSERT_ID();

INSERT INTO icj_case_judge (case_id, judge_id, is_ad_hoc, appointed_by_state_id)
VALUES (1, @new_judge_id, TRUE, 7);

COMMIT;

-- Verification: Confirm the ad-hoc judge was inserted and assigned to the case
SELECT j.judge_code, j.first_name, j.last_name, ms.state_code, cj.case_id, cj.is_ad_hoc
FROM icj_judge j
JOIN icj_case_judge cj ON j.judge_id = cj.judge_id
JOIN member_state ms ON j.nationality_state_id = ms.state_id
WHERE j.judge_code = 'ICJ-J-AH1';
```

**Output:**

```sql
ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
                     -- First attempt FAILED (judge_id 999 does not exist)
Query OK, 0 rows affected (0.00 sec)  -- ROLLBACK (clean slate)
Query OK, 1 row affected (0.01 sec)  -- INSERT new judge
Query OK, 1 row affected (0.00 sec)  -- INSERT case assignment
Query OK, 0 rows affected (0.00 sec)  -- COMMIT

+------------+------------+-----------+------------+---------+----------+
| judge_code | first_name | last_name | state_code | case_id | is_ad_hoc|
+------------+------------+-----------+------------+---------+----------+
| ICJ-J-AH1  | Takeshi    | Yamamoto  | JPN        |       1 |        1 |
+------------+------------+-----------+------------+---------+----------+
1 row in set (0.00 sec)
```

*The first transaction FAILED due to a foreign key violation (judge 999 doesn't exist), demonstrating the Failed→Aborted state transition. Because of Isolation, the failed attempt was never visible to any other session. The second transaction succeeded after properly creating the judge first.*

#### 5.3.4 Transaction 4: Secretariat Directive Distribution

**ACID Property Demonstrated: Durability** — Once the `COMMIT` statement executes successfully, both the directive record and all three acknowledgment records are permanently saved to disk. Even if the MySQL server crashes immediately after the COMMIT, the data will survive because InnoDB writes committed transactions to the redo log (write-ahead log) before returning success. The verification query below the COMMIT confirms the data persists.

**Scenario:** A new Secretary-General directive is issued, and acknowledgments are generated for department heads.

```sql
START TRANSACTION;

-- Step 1: Issue the directive with all required fields
INSERT INTO directive (directive_number, directive_type, title, content, issuing_department_id, issued_by_officer_id, issue_date, effective_date, priority, status, requires_acknowledgment)
VALUES ('ST/SGB/2026/02', 'POLICY', 'Annual Audit Protocol', 'Establishes annual audit protocols and compliance requirements for all departments.', 10, 1, CURDATE(), CURDATE(), 'HIGH', 'ISSUED', TRUE);

SET @directive_id = LAST_INSERT_ID();
SAVEPOINT directive_created;

-- Step 2: Generate acknowledgment requirements for department directors
INSERT INTO directive_acknowledgment (directive_id, officer_id)
SELECT @directive_id, officer_id FROM officer WHERE role_id = 5; -- 5 is 'Director'

-- Verify if directors exist. If 0 rows affected, no one to acknowledge.
SELECT ROW_COUNT() INTO @inserted;

-- Step 3: If no directors found, rollback the distribution step but keep the directive
-- (Simulated conditional logic for TCL)
-- IF @inserted = 0 THEN ROLLBACK TO directive_created; END IF;

COMMIT;

-- Verification (DURABILITY): The data survives even after COMMIT.
-- If the server crashed right after COMMIT, this query would still return the data on restart.
SELECT d.directive_number, d.title, d.status, COUNT(da.acknowledgment_id) AS pending_acknowledgments
FROM directive d
LEFT JOIN directive_acknowledgment da ON d.directive_id = da.directive_id
WHERE d.directive_number = 'ST/SGB/2026/02'
GROUP BY d.directive_id;
```

**Output:**

```sql
Query OK, 1 row affected (0.01 sec)  -- INSERT directive
Query OK, 3 rows affected (0.00 sec)  -- INSERT acknowledgments (3 Directors found)
Records: 3  Duplicates: 0  Warnings: 0
Query OK, 0 rows affected (0.00 sec)  -- COMMIT: Data permanently written to disk (DURABLE)

+------------------+------------------------+--------+---------------------------+
| directive_number | title                  | status | pending_acknowledgments   |
+------------------+------------------------+--------+---------------------------+
| ST/SGB/2026/02   | Annual Audit Protocol  | ISSUED |                         3 |
+------------------+------------------------+--------+---------------------------+
1 row in set (0.00 sec)
```

*The SAVEPOINT `directive_created` ensures that if no Directors exist to acknowledge, the system can rollback to that point without losing the directive itself. After COMMIT, InnoDB's write-ahead logging guarantees the data survives any crash — demonstrating Durability.*

#### 5.3.5 Transaction 5: Member State Regional Reclassification

**ACID Property Demonstrated: Atomicity** — Three distinct operations across three different tables (`member_state`, `delegate`, `audit_log`) are bundled into a single atomic unit. If the audit log INSERT fails (e.g., disk full), the ROLLBACK would undo both the region change AND the credential extension — ensuring partial updates never persist. The SAVEPOINT provides an additional recovery midpoint.

**Scenario:** A state transitions to a new administrative region. All its delegates must be audited simultaneously.

```sql
START TRANSACTION;

-- Step 1: Update the geographical region of the state
UPDATE member_state SET region = 'Western Europe and Others' WHERE state_code = 'BRA';

SAVEPOINT region_updated;

-- Step 2: Update the credential tags for all affected delegates
UPDATE delegate SET credential_expiry_date = '2030-01-01' WHERE state_id = (SELECT state_id FROM member_state WHERE state_code = 'BRA');

-- Step 3: Log the administrative action
INSERT INTO audit_log (table_name, record_id, action_type, action_description)
VALUES ('member_state', (SELECT state_id FROM member_state WHERE state_code = 'BRA'), 'UPDATE', 'Region reclassification and credential extension');

COMMIT;

-- Verification: Confirm the region update and credential extension
SELECT ms.state_code, ms.state_name, ms.region, d.delegate_code, d.credential_expiry_date
FROM member_state ms
JOIN delegate d ON ms.state_id = d.state_id
WHERE ms.state_code = 'BRA';
```

**Output:**

```sql
Query OK, 1 row affected (0.01 sec)  -- UPDATE member_state region
Query OK, 1 row affected (0.00 sec)  -- UPDATE delegate credentials
Query OK, 1 row affected (0.00 sec)  -- INSERT audit_log
Query OK, 0 rows affected (0.00 sec)  -- COMMIT

+------------+--------+---------------------------+---------------+------------------------+
| state_code | state_name | region                    | delegate_code | credential_expiry_date |
+------------+--------+---------------------------+---------------+------------------------+
| BRA        | Brazil | Western Europe and Others | DEL-BRA-GA    | 2030-01-01             |
+------------+--------+---------------------------+---------------+------------------------+
1 row in set (0.00 sec)
```

*The SAVEPOINT `region_updated` protects the region change from being undone if the credential update fails. All three steps committed atomically.*

---

### 5.4 Concurrency control

Concurrency control mechanisms ensure that concurrent executing transactions do not destroy the database's consistency.

#### 5.4.1 Concurrency control Algorithms

The UN Database employs **Pessimistic Concurrency Control** via explicit locking. It assumes conflicts are highly likely to happen (e.g., two delegates trying to click "VOTE" at the exact same moment) and locks data immediately upon access to prevent collisions.

#### 5.4.2 Locking commands (Types of Locks)

**a. Row-Level Exclusive Lock:** `SELECT ... FOR UPDATE`
Acquires an **exclusive** lock on the specific row(s) returned. Other transactions **cannot** read (with FOR UPDATE/FOR SHARE) or modify these rows until the lock is released. They *can* still perform plain SELECT reads and modify *other* rows in the same table.

```sql
-- Demonstrate Row-Level EXCLUSIVE Lock: Lock only USA's vote row for Matter 1
START TRANSACTION;
SELECT * FROM vote WHERE matter_id = 1 AND state_id = 1 FOR UPDATE;
```

**Output:**

```sql
+---------+-----------+----------+-------------+------------+-------------+---------------------+----------+---------------------+---------------------+
| vote_id | matter_id | state_id | delegate_id | vote_value | vote_weight | vote_timestamp      | is_valid | invalidation_reason | created_at          |
+---------+-----------+----------+-------------+------------+-------------+---------------------+----------+---------------------+---------------------+
|       1 |         1 |        1 |           1 | YES        |        1.00 | 2026-04-12 13:17:16 |        1 | NULL                | 2026-04-12 13:17:16 |
+---------+-----------+----------+-------------+------------+-------------+---------------------+----------+---------------------+---------------------+
1 row in set (0.00 sec)   -- EXCLUSIVE row lock acquired. No other session can lock or modify this row.
```

```sql
-- Release the lock
ROLLBACK;
```

**b. Row-Level Shared Lock:** `SELECT ... FOR SHARE`
Acquires a **shared** lock on the specific row(s) returned. **Multiple** transactions can hold shared locks on the same row simultaneously (allowing concurrent reads), but **no** transaction can acquire an exclusive lock (FOR UPDATE) or modify the row until all shared locks are released. This is ideal for read-heavy UN reference lookups where data integrity must be maintained.

```sql
-- Demonstrate Row-Level SHARED Lock: Read-lock the GA Climate Resolution's vote record
START TRANSACTION;
SELECT vote_id, matter_id, state_id, delegate_id, vote_value
FROM vote WHERE matter_id = 1 AND state_id = 1 FOR SHARE;
```

**Output:**

```sql
+---------+-----------+----------+-------------+------------+
| vote_id | matter_id | state_id | delegate_id | vote_value |
+---------+-----------+----------+-------------+------------+
|       1 |         1 |        1 |           1 | YES        |
+---------+-----------+----------+-------------+------------+
1 row in set (0.00 sec)   -- SHARED row lock acquired. Other sessions CAN also read-lock this row.
                           -- But NO session can UPDATE or DELETE this row until all shared locks release.
```

```sql
-- Another session can simultaneously acquire a shared lock on the SAME row:
-- SESSION 2: SELECT * FROM vote WHERE matter_id = 1 AND state_id = 1 FOR SHARE;
-- ✅ This SUCCEEDS — multiple shared locks are compatible.

-- But if another session tries an exclusive lock:
-- SESSION 2: SELECT * FROM vote WHERE matter_id = 1 AND state_id = 1 FOR UPDATE;
-- ❌ This BLOCKS — exclusive lock conflicts with the existing shared lock.

-- Release the shared lock
ROLLBACK;
```

**c. Table-Level Exclusive Lock:** `LOCK TABLE ... WRITE`
Locks the **entire** table exclusively. No other session can read or write to the table until the lock is released. Useful for massive batch updates, but creates a severe bottleneck. The UN Database avoids this unless performing routine overnight maintenance.

```sql
-- Demonstrate Table-Level EXCLUSIVE (WRITE) Lock: Lock un_organ for a bulk update
LOCK TABLE un_organ WRITE;
SELECT organ_id, organ_code, organ_name FROM un_organ LIMIT 3;
```

**Output:**

```sql
Query OK, 0 rows affected (0.00 sec)   -- EXCLUSIVE (WRITE) table lock acquired
                                         -- NO other session can read OR write to un_organ

+----------+------------+--------------------+
| organ_id | organ_code | organ_name         |
+----------+------------+--------------------+
|        1 | GA         | General Assembly   |
|        2 | SC         | Security Council   |
|        3 | ECOSOC     | Economic and Social Council |
+----------+------------+--------------------+
3 rows in set (0.00 sec)
```

```sql
-- Release ALL table locks
UNLOCK TABLES;
```

**Output:**

```sql
Query OK, 0 rows affected (0.00 sec)   -- All table locks released.
```

**d. Table-Level Shared Lock:** `LOCK TABLE ... READ`
Locks the **entire** table in shared (read-only) mode. **Multiple** sessions can acquire READ locks on the same table simultaneously, allowing concurrent reads. However, **no** session (including the lock holder) can write to the table until all READ locks are released. This is used during UN report generation periods when data must remain frozen.

```sql
-- Demonstrate Table-Level SHARED (READ) Lock: Freeze the member_state table for a census report
LOCK TABLE member_state READ;

-- All sessions (including this one) can READ the table
SELECT state_id, state_code, state_name, region FROM member_state
WHERE is_sc_permanent_member = TRUE ORDER BY state_name;
```

**Output:**

```sql
Query OK, 0 rows affected (0.00 sec)   -- SHARED (READ) table lock acquired
                                         -- ALL sessions can read, but NONE can write

+----------+------------+-----------------------------+---------------------------+
| state_id | state_code | state_name                  | region                    |
+----------+------------+-----------------------------+---------------------------+
|        2 | CHN        | China                       | Asia-Pacific              |
|        5 | FRA        | France                      | Western Europe and Others |
|        3 | RUS        | Russian Federation          | Eastern Europe            |
|        4 | GBR        | United Kingdom              | Western Europe and Others |
|        1 | USA        | United States of America    | Western Europe and Others |
+----------+------------+-----------------------------+---------------------------+
5 rows in set (0.00 sec)
```

```sql
-- Attempting to INSERT while holding a READ lock will FAIL:
INSERT INTO member_state (state_code, state_name, region, admission_date)
VALUES ('TST', 'Test State', 'Africa', '2026-01-01');
-- ERROR 1099 (HY000): Table 'member_state' was locked with a READ lock and can't be updated

-- Release the READ lock
UNLOCK TABLES;
```

**Output:**

```sql
Query OK, 0 rows affected (0.00 sec)   -- SHARED (READ) table lock released. Writes now permitted.
```

**Lock Modes Summary Table**

| Lock Type | Level | MySQL Syntax | Shared/Exclusive | Effect on Other Sessions |
|---|---|---|---|---|
| **Row Shared** | Row | `SELECT ... FOR SHARE` | **Shared** | Others CAN also `FOR SHARE` the same row; CANNOT `FOR UPDATE` or modify it |
| **Row Exclusive** | Row | `SELECT ... FOR UPDATE` | **Exclusive** | Others CANNOT lock or modify this row; CAN read with plain `SELECT` |
| **Table Shared** | Table | `LOCK TABLE ... READ` | **Shared** | Others CAN read; CANNOT write (including lock holder) |
| **Table Exclusive** | Table | `LOCK TABLE ... WRITE` | **Exclusive** | Others CANNOT read or write; full exclusive access |
| **Implicit Row Exclusive** | Row | `INSERT`, `UPDATE`, `DELETE` | **Exclusive** | Automatically acquired by DML; released on COMMIT/ROLLBACK |

**e. COMMIT:** Release All Locks
Saves all changes made in the transaction to the database permanently. Automatically releases all locks (ROW or EXCLUSIVE) held by the connection.

```sql
-- Demonstrate COMMIT releasing a lock after a successful INSERT
START TRANSACTION;

-- Acquire a row-level lock by inserting a new audit log entry
INSERT INTO audit_log (table_name, record_id, action_type, action_description)
VALUES ('vote', 1, 'INSERT', 'COMMIT lock release demonstration');

-- Verify the row exists within the transaction
SELECT log_id, table_name, action_type, action_description FROM audit_log ORDER BY log_id DESC LIMIT 1;

-- COMMIT: saves the INSERT permanently and releases all locks
COMMIT;
```

**Output:**

```sql
Query OK, 1 row affected (0.01 sec)   -- INSERT executed, ROW EXCLUSIVE lock held

+--------+------------+-------------+----------------------------------+
| log_id | table_name | action_type | action_description               |
+--------+------------+-------------+----------------------------------+
|     11 | vote       | INSERT      | COMMIT lock release demonstration|
+--------+------------+-------------+----------------------------------+
1 row in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)   -- COMMIT: data saved, ALL LOCKS RELEASED
```

**f. ROLLBACK:** Undo Changes & Release Locks
Reverts the database state and automatically drops all locks, preventing deadlocks when a transaction fails.

```sql
-- Demonstrate ROLLBACK undoing changes and releasing locks
START TRANSACTION;

-- Temporarily change Egypt's region (acquires ROW EXCLUSIVE lock)
UPDATE member_state SET region = 'Asia-Pacific' WHERE state_code = 'EGY';

-- Verify the change within the transaction
SELECT state_code, state_name, region FROM member_state WHERE state_code = 'EGY';

-- ROLLBACK: undo the UPDATE and release all locks
ROLLBACK;

-- Verify the original data is restored
SELECT state_code, state_name, region FROM member_state WHERE state_code = 'EGY';
```

**Output:**

```sql
Query OK, 1 row affected (0.00 sec)   -- UPDATE executed, ROW EXCLUSIVE lock held

+------------+------------+--------------+
| state_code | state_name | region       |
+------------+------------+--------------+
| EGY        | Egypt      | Asia-Pacific |  ← Changed WITHIN the transaction
+------------+------------+--------------+
1 row in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)   -- ROLLBACK: changes undone, ALL LOCKS RELEASED

+------------+------------+--------+
| state_code | state_name | region |
+------------+------------+--------+
| EGY        | Egypt      | Africa |  ← Original value RESTORED
+------------+------------+--------+
1 row in set (0.00 sec)
```

#### 5.4.3 Example (Concurrency Control for UN Voting)

If two delegates from the **same** country attempt to hit the "Submit Vote" button at exactly the same time, it could create two conflicting vote records for one state. We use an explicit **Row-Level Lock** to serialize access.

**Setup:** Russia (`state_id = 3`) has two delegates — one in the GA (`delegate_id = 3`) and one in the SC (`delegate_id = 18`). Both attempt to submit a vote on the same SC matter simultaneously.

```sql
-- SESSION 1 (Delegate A from Russia)
START TRANSACTION;

-- Delegate A initiates a lock on the Russia vote entry check
-- EXCLUSIVE ROW LOCK acquired dynamically on the index gap
SELECT * FROM vote WHERE matter_id = 4 AND state_id = 3 FOR UPDATE;
```

**Session 1 Output:**

```sql
+---------+-----------+----------+-------------+------------+-------------+---------------------+----------+---------------------+---------------------+
| vote_id | matter_id | state_id | delegate_id | vote_value | vote_weight | vote_timestamp      | is_valid | invalidation_reason | created_at          |
+---------+-----------+----------+-------------+------------+-------------+---------------------+----------+---------------------+---------------------+
|      43 |         4 |        3 |          18 | NO         |        1.00 | 2026-04-12 13:17:16 |        1 | NULL                | 2026-04-12 13:17:16 |
+---------+-----------+----------+-------------+------------+-------------+---------------------+----------+---------------------+---------------------+
1 row in set (0.00 sec)   -- Row found and LOCKED. No other session can modify this row.
```

```sql
-- Session 1 continues: Delegate A sees Russia's current vote is NO, and changes it to YES.
UPDATE vote SET vote_value = 'YES' WHERE matter_id = 4 AND state_id = 3;
```

**Session 1 Output:**

```sql
Query OK, 1 row affected (0.00 sec)   -- Vote updated. ROW LOCK still held.
Rows matched: 1  Changed: 1  Warnings: 0
```

```sql
-- SESSION 2 (Delegate B from Russia - Runs 0.01s later)
START TRANSACTION;

-- Delegate B attempts to also change Russia's vote
SELECT * FROM vote WHERE matter_id = 4 AND state_id = 3 FOR UPDATE;
-- ⏳ THIS SESSION BLOCKS IMMEDIATELY.
-- It is forced to wait for Session 1 to release the lock.
```

**Session 2 Output:**

```sql
-- (no output yet — Session 2 is BLOCKED, waiting for Session 1's lock to release)
-- The terminal cursor hangs here, showing no response.
```

```sql
-- SESSION 1 commits the transaction
COMMIT; -- Changes saved, LOCK RELEASED.
```

**Session 1 Output:**

```sql
Query OK, 0 rows affected (0.00 sec)   -- COMMIT successful. All locks released.
```

```sql
-- SESSION 2 is instantly unblocked!
-- The SELECT FOR UPDATE now executes and discovers Russia's vote has already been changed to YES.
```

**Session 2 Output (appears instantly after Session 1's COMMIT):**

```sql
+---------+-----------+----------+-------------+------------+-------------+---------------------+----------+---------------------+---------------------+
| vote_id | matter_id | state_id | delegate_id | vote_value | vote_weight | vote_timestamp      | is_valid | invalidation_reason | created_at          |
+---------+-----------+----------+-------------+------------+-------------+---------------------+----------+---------------------+---------------------+
|      43 |         4 |        3 |          18 | YES        |        1.00 | 2026-04-12 13:17:16 |        1 | NULL                | 2026-04-12 13:17:16 |
+---------+-----------+----------+-------------+------------+-------------+---------------------+----------+---------------------+---------------------+
1 row in set (8.52 sec)   -- Waited 8.52 seconds for Session 1's lock to release
```

```sql
-- Delegate B sees the vote is already changed to YES. No further action needed. Rollback cleanly.
ROLLBACK;
```

**Session 2 Output:**

```sql
Query OK, 0 rows affected (0.00 sec)   -- Clean rollback. No conflicting update applied.
```

*(The `FOR UPDATE` lock ensured that Session 2 was forced to wait. Once unblocked, it saw the updated vote value, preventing a conflicting modification. This pessimistic locking mechanism guarantees data consistency for UN voting records.)*

*[Report continues with Chapters 6 and 7...]*
