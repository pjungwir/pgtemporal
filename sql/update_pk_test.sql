INSERT INTO houses VALUES 
  (1, 150000, tstzrange('2015-01-01', '2016-01-01')),
  (1, 200000, tstzrange('2016-01-01', '2017-01-01')),
  (2, 300000, tstzrange('2015-01-01', '2016-01-01')),
  (3, 100000, tstzrange('2014-01-01', '2015-01-01')),
  (3, 200000, tstzrange('2015-01-01', null))
;


-- ON UPDATE RESTRICT
SELECT create_temporal_foreign_key('room_has_a_house', 'rooms', 'house_id', 'valid_at', 'houses', 'id', 'valid_at');

-- You can update a finite pk id with no references
UPDATE houses SET id = 4 WHERE id = 1;
UPDATE houses SET id = 1 WHERE id = 4;

-- You can update a finite pk range with no references
UPDATE houses SET valid_at = tstzrange('1999-01-01', '2000-01-01') WHERE id = 1 AND valid_at @> '2015-06-01'::timestamptz;
UPDATE houses SET valid_at = tstzrange('2015-01-01', '2016-01-01') WHERE id = 1 AND valid_at @> '1999-06-01'::timestamptz;

-- You can update a finite pk range that is partly covered elsewhere
INSERT INTO rooms VALUES (1, 1, tstzrange('2016-01-01', '2016-06-01'));
UPDATE houses SET valid_at = tstzrange('2016-01-01', '2016-09-01') WHERE id = 1 AND valid_at @> '2016-06-01'::timestamptz;
UPDATE houses SET valid_at = tstzrange('2016-01-01', '2017-01-01') WHERE id = 1 AND valid_at @> '2016-06-01'::timestamptz;
DELETE FROM rooms;

-- You can't update a finite pk id that is partly covered
INSERT INTO rooms VALUES (1, 1, tstzrange('2016-01-01', '2016-06-01'));
UPDATE houses SET id = 4 WHERE id = 1;
DELETE FROM rooms;

-- You can't update a finite pk range that is partly covered
INSERT INTO rooms VALUES (1, 1, tstzrange('2016-01-01', '2016-06-01'));
UPDATE houses SET valid_at = tstzrange('2017-01-01', '2018-01-01') WHERE id = 1 AND valid_at @> '2016-06-01'::timestamptz;
DELETE FROM rooms;

-- You can't update a finite pk id that is exactly covered
INSERT INTO rooms VALUES (1, 1, tstzrange('2016-01-01', '2017-01-01'));
UPDATE houses SET id = 4 WHERE id = 1;
DELETE FROM rooms;

-- You can't update a finite pk range that is exactly covered
INSERT INTO rooms VALUES (1, 1, tstzrange('2016-01-01', '2017-01-01'));
UPDATE houses SET valid_at = tstzrange('2017-01-01', '2018-01-01') WHERE id = 1 AND valid_at @> '2016-06-01'::timestamptz;
DELETE FROM rooms;

-- You can't update a finite pk id that is more than covered
INSERT INTO rooms VALUES (1, 1, tstzrange('2015-06-01', '2017-01-01'));
UPDATE houses SET id = 4 WHERE id = 1;
DELETE FROM rooms;

-- You can't update a finite pk range that is more than covered
INSERT INTO rooms VALUES (1, 1, tstzrange('2015-06-01', '2017-01-01'));
UPDATE houses SET valid_at = tstzrange('2017-01-01', '2018-01-01') WHERE id = 1 AND valid_at @> '2016-06-01'::timestamptz;
DELETE FROM rooms;

-- You can update an infinite pk id with no references
INSERT INTO rooms VALUES (1, 3, tstzrange('2014-06-01', '2015-01-01'));
UPDATE houses SET id = 4 WHERE id = 3 and valid_at @> '2016-01-01'::timestamptz;
UPDATE houses SET id = 3 WHERE id = 4;
DELETE FROM rooms;

-- You can update an infinite pk range with no references
INSERT INTO rooms VALUES (1, 3, tstzrange('2014-06-01', '2015-01-01'));
UPDATE houses SET valid_at = tstzrange('2017-01-01', '2018-01-01') WHERE id = 3 and valid_at @> '2016-01-01'::timestamptz;
UPDATE houses SET valid_at = tstzrange('2015-01-01', null) WHERE id = 3 and valid_at @> '2017-06-01'::timestamptz;
DELETE FROM rooms;

-- You can't update an infinite pk id that is partly covered
INSERT INTO rooms VALUES (1, 3, tstzrange('2016-01-01', '2017-01-01'));
UPDATE houses SET id = 4 WHERE id = 3 and valid_at @> '2016-01-01'::timestamptz;
DELETE FROM rooms;

-- You can't update an infinite pk range that is partly covered
INSERT INTO rooms VALUES (1, 3, tstzrange('2016-01-01', '2017-01-01'));
UPDATE houses SET valid_at = tstzrange('2017-01-01', '2018-01-01') WHERE id = 3 and valid_at @> '2016-01-01'::timestamptz;
DELETE FROM rooms;

-- You can't update an infinite pk id that is exactly covered
INSERT INTO rooms VALUES (1, 3, tstzrange('2015-01-01', null));
UPDATE houses SET id = 4 WHERE id = 3 and valid_at @> '2016-01-01'::timestamptz;
DELETE FROM rooms;

-- You can't update an infinite pk range that is exactly covered
INSERT INTO rooms VALUES (1, 3, tstzrange('2015-01-01', null));
UPDATE  houses SET valid_at = tstzrange('2017-01-01', '2018-01-01') WHERE id = 3 and valid_at @> '2016-01-01'::timestamptz;
DELETE FROM rooms;

-- You can't update an infinite pk id that is more than covered
INSERT INTO rooms VALUES (1, 3, tstzrange('2014-06-01', null));
UPDATE houses SET id = 4 WHERE id = 3 and valid_at @> '2016-01-01'::timestamptz;
DELETE FROM rooms;

-- You can't update an infinite pk range that is more than covered
INSERT INTO rooms VALUES (1, 3, tstzrange('2014-06-01', null));
UPDATE houses SET valid_at = tstzrange('2017-01-01', '2018-01-01') WHERE id = 3 and valid_at @> '2016-01-01'::timestamptz;
DELETE FROM rooms;

-- ON UPDATE NOACTION
-- TODO

-- ON UPDATE CASCADE
-- TODO

-- ON UPDATE SET NULL
-- TODO

-- ON UPDATE SET DEFAULT
-- TODO

DELETE FROM rooms;
DELETE FROM houses;
SELECT drop_temporal_foreign_key('room_has_a_house', 'rooms', 'houses');
