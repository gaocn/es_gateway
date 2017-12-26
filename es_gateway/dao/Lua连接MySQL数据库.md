
## luasql.mysql��������
``` lua
require "luasql.mysql"

--������������
env = luasql.mysql()

--�������ݿ�
conn = env:connect("���ݿ���","�û���","����","IP��ַ",�˿�)

--�������ݿ�ı����ʽ
conn:execute"SET NAMES UTF8"

--ִ�����ݿ����
cur = conn:execute("select * from role")

row = cur:fetch({},"a")

--�ļ�����Ĵ���
file = io.open("role.txt","w+");

while row do
    var = string.format("%d %s\n", row.id, row.name)

    print(var)

    file:write(var)

    row = cur:fetch(row,"a")
end


file:close()  --�ر��ļ�����
conn:close()  --�ر����ݿ�����
env:close()   --�ر����ݿ⻷��
```

## ִ��MySQL����

```lua
--��ʼ����  
conn:execute([[START TRANSACTION;]])
--�ع�����
conn:execute([[ROLLBACK;]])
--�ύ����
conn:execute([[COMMIT;]])

```


## ����ģʽ
factory: ���������ļ����������ݿ���󣻸��������ļ�ָ�������ݿ����ͼ�����Ӧ�����ݿ������





```mermaid
graph TB
  F[Factory]
  M[MySQL]
  P[Postgres]
  C[Cassandra]
  d[...]
  I>DAO�ӿ�]
  F ==>|config| M
  F ==>|config| P
  F ==>|config| C
  F ==>|config| d
  �������ݿ����Ӷ��� -->|config| F
  M -.->|ʵ��| I
  P -.->|ʵ��| I
  C -.->|ʵ��| I
  d -.->|ʵ��| I
  T1((UserDAO))
  T2((PwdDAO))
  T3((ApiDAO))
  M --> T1
  M --> T2
  M --> T3
  T1---note(ÿһ��DAO��Ӧ�ڴ򿪵��Ǹ���)
  T2---note(ÿһ��DAO��Ӧ�ڴ򿪵��Ǹ���)
  T3---note(ÿһ��DAO��Ӧ�ڴ򿪵��Ǹ���)
```





