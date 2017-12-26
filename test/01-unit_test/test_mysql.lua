--
-- User: ������
-- Date: 2017/12/25
-- Description: 
--
package.path = package.path ..';..\\?.lua';
require "luasql.mysql"

local mysql =luasql.mysql()
assert(mysql)

--����mysql����
--local conn = mysql:connect("","root","gaowenwen","localhost",3306)
local conn, err = mysql:connect("db_name","root","gaowenwen","localhost",3306)
assert(conn)

--�������ݿ�����ʽ
conn:execute("SET NAMES UTF8")

local cur = conn:execute([[SHOW  DATABASES;]])
local row = cur:fetch("","a")

while row do
    print(row)
    row = cur:fetch(row, "a")
end

cur = conn:execute([[SELECT host, user, password FROM mysql.user;]])
assert(cur)
row = cur:fetch({}, "a")

while row do
    print(string.format("host: %s, usesr: %s, password: %s", row.host, row.user, row.password))
    row = cur:fetch(row, "a")
end

--create databases
--�������ɹ�ok=1����ʧ��okΪnil��
local ok,err = conn:execute([[CREATE DATABASE gateway;]])
print(ok, err)

conn:execute([[USE gateway;]])

--create  table ִ�гɹ�ok=0��errΪnil������okΪ�գ�errΪ����ԭ��
ok,err  =  conn:execute([[
    CREATE TABLE test(
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
        name varchar(20) NOT NULL,
        description text NOT NULL,
        date TIMESTAMP NOT NULL default CURRENT_TIMESTAMP,
        PRIMARY KEY(id)
    )ENGINE=InnoDB DEFAULT CHARSET=utf8;
]])
print(ok, err)

--insert �������ɹ�ok=1��ʾ����������Ӱ����������ʧ��okΪnil
ok, err = conn:execute([[
    INSERT INTO test(name, description) values('lua1','this is from test_mysql1');
]])
ok, err = conn:execute([[
    INSERT INTO test(name, description) values('lua2','this is from test_mysql2');
]])
ok, err = conn:execute([[
    INSERT INTO test(name, description) values('lua3','this is from test_mysql3');
]])
ok, err = conn:execute([[
    INSERT INTO test(name, description) values('lua4','this is from test_mysql4');
]])
print(ok, err)

--update�������ɹ�ok=n��ʾӰ����������ʧ��okΪnil
ok, err = conn:execute([[
    UPDATE test SET name="LUA_FORU"
    WHERE id=1
]])

ok, err = conn:execute([[
    UPDATE test SET name='DATE_UPDATE_FORU'
    WHERE date >'2017-12-25 10:44:30' AND date <= '2017-12-25 10:46:27'
]])
print(ok,  err)

--delete �������ɹ�ok=n��ʾӰ����������ʧ��okΪnil
ok, err = conn:execute([[
    DELETE FROM test
    WHERE date >= '2017-12-25 10:51:43'
]])
print(ok, err)

--select
local cur = conn:execute([[
    SELECT * FROM test
    WHERE name = 'DATE_UPDATE_FORU'
]])
assert(cur)
local data = {}
local row = {}
row = cur:fetch(row, "a")
while row do
    data[#data+1] = row
    row = cur:fetch(row, "a")
end

print("data len: ", #data)
print("data: ", unpack(data))

--truncate table ִ�гɹ�ok=0��errΪnil������okΪ�գ�errΪ����ԭ��
--ok, err = conn:execute([[
--    TRUNCATE TABLE test;
--]])
--print(ok, errs)

--delete table ִ�гɹ�ok=0��errΪnil������okΪ�գ�errΪ����ԭ��
--ok, err = conn:execute([[
--    DROP TABLE test;
--]])
--print(ok, errs)

--delete database ִ�гɹ�ok=0��errΪnil������okΪ�գ�errΪ����ԭ��
--ok, err = conn:execute([[
--    DROP DATABASE gateway1;
--]])
--print(ok, errs)

--�ر����Ӷ���
conn:close()
--�ر����ݿ⻷��
mysql:close()