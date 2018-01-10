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
local conn, err = mysql:connect("","root","gaowenwen","localhost",3306)
--local conn, err = mysql:connect("db_name","root","gaowenwen","localhost",3306)
assert(conn, err)

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

local o  = setmetatable({},{
    __call = function(_, schema)
        print('WWWWWWWWWWWWWWWWW')
        local mt = {}
        mt.__meta = {
            __schema  = schema
        }

        function mt.__index(_, key)
            print(key)
        end

        return setmetatable({}, {
            __call = function(_, tb)
                print('TTTTTTTT')
                local m = {}
                for  k, v in pairs(tb) do
                    m[k] = v
                end
                return setmetatable(m, mt)
            end
        })
    end

})

local schema = {
    table = 't_test',
    primary_kay =  'id',
    fields = {
        id =  {type = string, unique = true}
    }
}

local str_utils = require "es_gateway.utils.string"
local split = str_utils.split

local reply = "730bac5b_kibana,apm,ararat,araratserver,arrow,asmp,atii_bs,bac,bdp_ubs,beehive,boor,btcm,cccs,ccob,chargesystem,cmcs,cms,cofsp,csr,csup,e3c-asdispatcher,e3c-mip,e3cmonitor,e3cmonitor2cm,e3cmonitor2etcm,e3cmonitor-as,ebafs,ebb,ebfee,ebfeemb,ebftest,ebf-test,ebim,ebiz,ebms,ebom,ebup,ebupccsbz2,ebupccsbz3,ebupccsint,ebupdetail,ebus,erps,fpbqs,fpbqsservice,fqz_ebus,fqz_mbank,fqz_perbank,hanfeng,heartbeatlog_beehive,ics3,iept,ikms,logstash,mbank,mcs3,mocktest,oauth,obs,obs1,obs-filebeat,oebs-de,oebs-jp,oebs-sg,oibs-lux,oibs-luxbr,opuup,panadmin,perbank,perbankapps,perbanktaskschedule,pperbank,pprefix,ptp,qpay,qpayxn,ship,sjsh-jfbatch,sjsh-jfopenweb,sjsh-jfpcweb,sjsh-jfservice,sjsh-jfweb,sjsh-manageweb,sjsh-refservice,sjsh-refweb,sjsh-service,sjsh-yhbatch,sjsh-yhnmservice,sjsh-yhservice,sjsh-yhweb,sjsh-yhwifiweb,sjsh-yxbatch,sjsh-yxservice,sjsh-yxweb,sjsh-yxwxweb,taihang,udesk,ulog,uloggateway,upayrecon,wbp,wcss,zft"
local indices = split('ararat,araratserver', ',')
local replyT = split(reply, ',')

if type(replyT) ~= 'string' then
    print("parameter[AuthIndices] must be a string")
    replyT = tostring(unpack(replyT))
end


for _, v in ipairs(indices) do
    print(replyT:find(v))
end