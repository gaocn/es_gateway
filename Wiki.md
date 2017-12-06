# Lua Basics

### Lua Metatable

metatable是被译作元表，Lua 中的每个值都可以用一个metatable。这个metatable 就是一个原始的Lua table ，它用来定义原始值在特定操作下的行为。一个 metatable 可以控制一个对象做数学运算操作、比较操作、连接操作、取长度操作、取下标操作时的行为，metatable 中还可以定义一个函数，让 userdata 作垃圾收集时调用它。对于这些操作，Lua 都将其关联上一个被称作事件的指定健。当 Lua 需要对一个值发起这些操作中的一个时，它会去检查值中 metatable 中是否有对应事件。如果有的话，键名对应的值（元方法）将控制 Lua 怎样做这个操作。

metatable通过其包含的函数来给所挂接的table定义一些特殊的操作，包括:
- __add: 定义所挂接table的加法操作
- __mul: 定义乘法操作
- __div: 定义除法操作
- __sub: 定义减法操作
- __unm: 定义负操作, 即: -table的含义
- __tostring: 定义当table作为tostring()函式之参数被呼叫时的行为(例如: print(table)时将呼叫tostring(table)作为输出结果)
- __concat: 定义连接操作(".."运算符)
- __index: 定义当table中不存在的key值被试图获取时的行为
- __newindex: 定义在table中产生新key值时的行为

## setmetatable用于继承
setmetatable( obj, { __index = module } ) module为希望继承的模块名。

``` 
    local _S = {
        _LEVELS = 2
    }
    function _S.log(...)
        print("This is a log msg")
    end

    local M = setmetatable(_S, {
        __call = function(t, a, b)
            print('Another Test')
        end,
        __call = function(t, a)
            print(a)
        end,
        __index = function (t, key)
            print(key)
            return rawget(t, key)
        end
    })

    M("Nihao", "threw hao") ---> 会调用M中定义的方法签名为(table, param_a, param_b)的函数
    M.log() ---> 会调用继承自_S的方法，类似面向切面编程
```



### require、module与Lua搜索路径

- package.path：保存加载外部模块(lua中"模块"和"文件"这两个概念的分界比较含糊，因为这个值在不同的时刻会扮演不同的角色)的搜索路径。初始值可以通过环境变量LUA_PATH设置。

- package.cpath：用于加载第三方c库的。它的初始值可以通过环境变量LUA_CPATH设置。

- package.loadlib(libname, func):相当与手工打开c库libname, 并导出函数func返回。

``` 
   模式替换： ./?.lua
   会将包名为es_gateway.utils.logger.lua替换为es_gateway/utils/logger后在进行搜索
```

require(module)处理流程

1. 在package.loaded中查找module，若模块存在，则直接返回它的值；
2. 在package.preload中查看module，若preload存在，则将它作为loader，调用loader(L)；
3. 在packege.path中查找名称为module的lua文件，若找到lua会根据lua文件直接完成一个loader的初始化过程；
4. 在package.cpath查找c库，lua先已动态的方式加载该c库，然后在库中查找并调用相应名字的接口，例如：luaopen_hello_world；

module(name, cb1, cb2, ...)处理流程

1. 如果package.loaded[name]是一个table，那么就把这个table作为一个mod；
2. 如果全局变量name是一个table，就把这个全局变量作为一个mod；
3. 创建table:t = {[name]=package.loaded[name], ["_NAME"]=name, ["_M"]=t, ["_PACKAGE"]=*name*(删除了最后的".XXXX"部分)}. 如果name是一个以点分割的串，那么得到的mod类似这个样子：
         hello.world==> {["hello"]={["world"]={XXXXXXX}}}；
4. 依次调用cbs：cb1(mod), cb2(mod),...；
5. 将当前模块的环境设置为mod,同时把package.loaded[name] = mod；




## 常见错误

### Attempt to Index a Boolean Value

在使用require加载lua文件时，若该lua文件没有返回值，默认返回boolean类型的值，true表示加载模块成功，false表示加载模块失败。
    
