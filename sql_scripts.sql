--Таблица каталога продуктов
CREATE TABLE catalog (
cid NUMBER,
par_cid NUMBER,
rname VARCHAR2 (400 CHAR),
rdescr VARCHAR2 (4000 CHAR),
rcdate DATE,
CONSTRAINTS pk_cid PRIMARY KEY (cid),
CONSTRAINTS fk_par_cid FOREIGN KEY (par_cid)
REFERENCES catalog (cid)
);
INSERT ALL
INTO catalog VALUES (1, NULL, 'Комплектующие', 'элементы компьютера', sysdate)
INTO catalog VALUES (2, 1, 'Процессор', 
'Процессором называется устройство, способное обрабатывать программный код и определяющее основные функции компьютера по обработке информации', sysdate)
INTO catalog VALUES (3, 1, 'Видеокарта', 'устройство, преобразующее графический образ, хранящийся как содержимое памяти компьютера, в форму, 
пригодную для дальнейшего вывода на экран монитора.', sysdate)
INTO catalog VALUES (4, 1, 'Жесткий диск', 'запоминающее устройство произвольного доступа, основанное на принципе магнитной записи', sysdate)
INTO catalog VALUES (5, 1, 'Материнская плата', 'печатная плата, являющаяся основой построения модульного устройства', sysdate)
INTO catalog VALUES (6, 4, 'SSD', 'Твердотельный накопитель', sysdate)
INTO catalog VALUES (7, 4, 'HDD', 'Накопи?тель на жёстких магни?тных ди?сках', sysdate)
INTO catalog VALUES (8, NULL, 'Периферия', 'Устройства ввода/вывода', sysdate)
INTO catalog VALUES (9, 8, 'Мышка', 'Устройство ввода', sysdate)
INTO catalog VALUES (10, 8, 'Колонки', 'Устройство вывода', sysdate)
INTO catalog VALUES (11, 8, 'Клавиатура', 'Устройство ввода', sysdate)
SELECT * FROM DUAL;
COMMIT;
------------------------------------------------
--Таблица людей, ответственных за продажу
CREATE TABLE persons (
id NUMBER,
name VARCHAR2 (200 CHAR),
surname VARCHAR2 (200 CHAR),
CONSTRAINTS pk_id PRIMARY KEY (id)
);
INSERT ALL 
INTO persons VALUES (1, 'Иван', 'Иванов')
INTO persons VALUES (2, 'Петр', 'Петров')
INTO persons VALUES (3, 'Сидр', 'Сидоров')
SELECT * FROM DUAL;
-- Таблица измерений
CREATE TABLE units (
un_id NUMBER,
dimens VARCHAR2 (50 CHAR),
CONSTRAINTS pk_un_id PRIMARY KEY (un_id)
);
INSERT INTO units VALUES (1, 'штуки');
-- таблица продуктов
CREATE TABLE products (
pid NUMBER,
rcid NUMBER,
pname VARCHAR2 (500 CHAR),
pdescr VARCHAR2 (4000 CHAR),
punit NUMBER,
pper NUMBER,
CONSTRAINTS pk_pid PRIMARY KEY (pid),
CONSTRAINTS fk_rcid FOREIGN KEY (rcid)
REFERENCES catalog (cid)
);
INSERT ALL
INTO products VALUES (1, 2, 'Intel-Core-I7', 'семейство микропроцессоров Intel с архитектурой X86-64',
1,1)
INTO products VALUES (2, 3, 'RX-580', 'Потрясающая виртуальная реальность',
1,2)
INTO products VALUES (3, 6, 'Kingston', 'Невероятно быстрый',
1,3)
INTO products VALUES (4, 7, 'WD-blue', 'Большой объем!',
1,3)
INTO products VALUES (5, 5, 'Klissre-x79', 'лучшее соотношение цена/качество',
1,1)
INTO products VALUES (6, 9, 'XIAOMI GAMING MOUSE', 'лучшая игровая мышь',
1,2)
INTO products VALUES (7, 10, 'Sven', 'Потрясающий звук!',
1,2)
INTO products VALUES (8, 11, 'Razer', 'отзывчивость',
1,2)
INTO products VALUES (9, 9, 'Logitech', 'Бюджетный вариант',
1,2)
INTO products VALUES (10, 3, 'RTX - 2080TI', '----',
1,2)
INTO products VALUES (11, 2, 'Razen', 'Главный конкурент intel',
1,2)
SELECT * FROM DUAL;
COMMIT;
--------------------------------------------------------------
-- таблица движения продуктов
CREATE TABLE records (
rpid NUMBER,
rdate DATE,
incoming VARCHAR2 (2 CHAR) DEFAULT '1',
quantity NUMBER,
rate NUMBER,
CONSTRAINTS pk_rpid FOREIGN KEY (rpid)
REFERENCES products (pid)
);

INSERT ALL
INTO records VALUES (1, sysdate, DEFAULT, 100, 10000)
INTO records VALUES (2, sysdate, DEFAULT, 150, 20000)
INTO records VALUES (3, sysdate, DEFAULT, 500, 4000)
INTO records VALUES (4, sysdate, DEFAULT, 1000, 2500)
INTO records VALUES (5, sysdate, DEFAULT, 1000, 7000)
INTO records VALUES (1, sysdate, 0, 70, 10000)
INTO records VALUES (2, sysdate, 0, 100, 20000)
INTO records VALUES (3, sysdate, 0, 350, 4000)
INTO records VALUES (4, sysdate, 0, 650, 2500)
INTO records VALUES (5, sysdate, 0, 800, 7000)
INTO records VALUES (5, sysdate, 0, 800, 7000)
INTO records VALUES (6, sysdate, DEFAULT, 1200, 3000)
INTO records VALUES (7, sysdate, DEFAULT, 500, 1000)
INTO records VALUES (8, sysdate, DEFAULT, 350, 6000)
INTO records VALUES (9, sysdate, DEFAULT, 400, 800)
INTO records VALUES (10, sysdate, DEFAULT, 250, 80000)
INTO records VALUES (11, sysdate, DEFAULT, 350, 8000)
SELECT * FROM DUAL;
COMMIT;
-- таблица для хранения суммы товаров по разделам
CREATE TABLE SUMMA (
cid NUMBER,
par_cid NUMBER,
rname VARCHAR2 (400 CHAR),
level1 INTEGER, -- уровень вложенности
summa_arrival INTEGER,-- сумма поступивших товаров
summa_consum INTEGER -- сумма расходованных товаров
);
-- промежуточная таблица для подсчета суммы
CREATE TABLE SUMMA2 (
rcid NUMBER,
summa_arrival INTEGER,
summa_consum INTEGER
);

DECLARE max_level INTEGER; -- Переменная для хранения максимальной вложенности
BEGIN
-- Записываем изначальные данные в таблицу сумма
INSERT INTO summa 
SELECT cid, par_cid, rname, level, NULL AS summa_arrival, NULL AS summa_consum
FROM catalog
START WITH par_cid IS NULL
CONNECT BY PRIOR cid = par_cid;
-- вставляем в сумма2 суммарную стоимость товара
INSERT INTO summa2
SELECT rcid, SUM (DECODE (incoming, '1',rate * quantity)) AS summa_arrival, 
SUM (DECODE (incoming, '0',rate * quantity)) AS summa_consum
FROM records INNER JOIN products
ON rpid=pid
GROUP BY rcid;
-- обновляем сумма поступивших товаров и сумма расходованных товаров в таблице сумма
MERGE INTO summa 
USING summa2 ON (summa.cid = SUMMA2.rcid)
WHEN MATCHED THEN
UPDATE SET summa.summa_arrival = summa2.summa_arrival;
MERGE INTO summa 
USING summa2 ON (summa.cid = SUMMA2.rcid)
WHEN MATCHED THEN
UPDATE SET summa.summa_consum = summa2.summa_consum;
SELECT MAX(level1) INTO max_level FROM summa;
-- Подсчет итоговых значений
WHILE (max_level > 0) LOOP
INSERT INTO summa2
SELECT par_cid, SUM (DECODE (incoming, '1',rate * quantity)) AS summa_arrival,
SUM (DECODE (incoming, '0',rate * quantity)) AS summa_consum
FROM summa INNER JOIN products  ON rcid = cid
INNER JOIN records ON rpid = pid
WHERE level1=max_level
GROUP BY par_cid;
-- обновляем сумма поступивших товаров и сумма расходованных товаров в таблице сумма
MERGE INTO summa 
USING summa2 ON (summa.cid = SUMMA2.rcid)
WHEN MATCHED THEN
UPDATE SET summa.summa_arrival = summa2.summa_arrival;
MERGE INTO summa 
USING summa2 ON (summa.cid = SUMMA2.rcid)
WHEN MATCHED THEN
UPDATE SET summa.summa_consum = summa2.summa_consum;
max_level := max_level - 1;
END LOOP;
END;
COMMIT;

SELECT *
FROM summa;

SELECT c.cid AS section, c.rname AS name_section,
pname AS name_product, tb2.rate AS price,
summa_arrival, summa_consum, quantity_arrival, quantity_consum, 
quantity_arrival-quantity_consum AS remainder
FROM catalog c,
(
  SELECT P.rcid, SUM (DECODE (incoming, '1',r.rate * r.quantity)) AS summa_arrival,
  SUM (DECODE (incoming, '0',r.rate * r.quantity)) AS summa_consum,
  SUM (DECODE (incoming, '1',r.quantity)) as quantity_arrival, 
  SUM (DECODE (incoming, '0',r.quantity)) as quantity_consum,
  r.rate,  p.pname
  FROM products P, records r
  WHERE P.pid = r.RPID
  GROUP BY P.RCID, pname, rate
)tb2
 WHERE tb2.rcid = c.cid
 CONNECT BY PRIOR cid = par_cid;
 