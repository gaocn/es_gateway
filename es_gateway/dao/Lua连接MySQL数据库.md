
## luasql.mysql基本操作
``` lua
require "luasql.mysql"

--创建环境对象
env = luasql.mysql()

--连接数据库
conn = env:connect("数据库名","用户名","密码","IP地址",端口)

--设置数据库的编码格式
conn:execute"SET NAMES UTF8"

--执行数据库操作
cur = conn:execute("select * from role")

row = cur:fetch({},"a")

--文件对象的创建
file = io.open("role.txt","w+");

while row do
    var = string.format("%d %s\n", row.id, row.name)

    print(var)

    file:write(var)

    row = cur:fetch(row,"a")
end


file:close()  --关闭文件对象
conn:close()  --关闭数据库连接
env:close()   --关闭数据库环境
```

## 执行MySQL事务

```lua
--开始事务  
conn:execute([[START TRANSACTION;]])
--回滚事务
conn:execute([[ROLLBACK;]])
--提交事务
conn:execute([[COMMIT;]])

```


## 工厂模式
factory: 传入配置文件，建立数据库对象；根据配置文件指定的数据库类型加载相应的数据库操作；





```mermaid
graph TB
  F[Factory]
  M[MySQL]
  P[Postgres]
  C[Cassandra]
  d[...]
  I>DAO接口]
  F ==>|config| M
  F ==>|config| P
  F ==>|config| C
  F ==>|config| d
  返回数据库连接对象 -->|config| F
  M -.->|实现| I
  P -.->|实现| I
  C -.->|实现| I
  d -.->|实现| I
  T1((UserDAO))
  T2((PwdDAO))
  T3((ApiDAO))
  M --> T1
  M --> T2
  M --> T3
  T1---note(每一个DAO对应于打开的那个表)
  T2---note(每一个DAO对应于打开的那个表)
  T3---note(每一个DAO对应于打开的那个表)
```





