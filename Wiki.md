# Lua Basics

### Lua Metatable

metatable�Ǳ�����Ԫ��Lua �е�ÿ��ֵ��������һ��metatable�����metatable ����һ��ԭʼ��Lua table ������������ԭʼֵ���ض������µ���Ϊ��һ�� metatable ���Կ���һ����������ѧ����������Ƚϲ��������Ӳ�����ȡ���Ȳ�����ȡ�±����ʱ����Ϊ��metatable �л����Զ���һ���������� userdata �������ռ�ʱ��������������Щ������Lua �����������һ���������¼���ָ�������� Lua ��Ҫ��һ��ֵ������Щ�����е�һ��ʱ������ȥ���ֵ�� metatable ���Ƿ��ж�Ӧ�¼�������еĻ���������Ӧ��ֵ��Ԫ������������ Lua ���������������

metatableͨ��������ĺ����������ҽӵ�table����һЩ����Ĳ���������:
- __add: �������ҽ�table�ļӷ�����
- __mul: ����˷�����
- __div: �����������
- __sub: �����������
- __unm: ���帺����, ��: -table�ĺ���
- __tostring: ���嵱table��Ϊtostring()��ʽ֮����������ʱ����Ϊ(����: print(table)ʱ������tostring(table)��Ϊ������)
- __concat: �������Ӳ���(".."�����)
- __index: ���嵱table�в����ڵ�keyֵ����ͼ��ȡʱ����Ϊ
- __newindex: ������table�в�����keyֵʱ����Ϊ

## setmetatable���ڼ̳�
setmetatable( obj, { __index = module } ) moduleΪϣ���̳е�ģ������

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

    M("Nihao", "threw hao") ---> �����M�ж���ķ���ǩ��Ϊ(table, param_a, param_b)�ĺ���
    M.log() ---> ����ü̳���_S�ķ�������������������
```



### require��module��Lua����·��

- package.path����������ⲿģ��(lua��"ģ��"��"�ļ�"����������ķֽ�ȽϺ�������Ϊ���ֵ�ڲ�ͬ��ʱ�̻���ݲ�ͬ�Ľ�ɫ)������·������ʼֵ����ͨ����������LUA_PATH���á�

- package.cpath�����ڼ��ص�����c��ġ����ĳ�ʼֵ����ͨ����������LUA_CPATH���á�

- package.loadlib(libname, func):�൱���ֹ���c��libname, ����������func���ء�

``` 
   ģʽ�滻�� ./?.lua
   �Ὣ����Ϊes_gateway.utils.logger.lua�滻Ϊes_gateway/utils/logger���ڽ�������
```

require(module)��������

1. ��package.loaded�в���module����ģ����ڣ���ֱ�ӷ�������ֵ��
2. ��package.preload�в鿴module����preload���ڣ�������Ϊloader������loader(L)��
3. ��packege.path�в�������Ϊmodule��lua�ļ������ҵ�lua�����lua�ļ�ֱ�����һ��loader�ĳ�ʼ�����̣�
4. ��package.cpath����c�⣬lua���Ѷ�̬�ķ�ʽ���ظ�c�⣬Ȼ���ڿ��в��Ҳ�������Ӧ���ֵĽӿڣ����磺luaopen_hello_world��

module(name, cb1, cb2, ...)��������

1. ���package.loaded[name]��һ��table����ô�Ͱ����table��Ϊһ��mod��
2. ���ȫ�ֱ���name��һ��table���Ͱ����ȫ�ֱ�����Ϊһ��mod��
3. ����table:t = {[name]=package.loaded[name], ["_NAME"]=name, ["_M"]=t, ["_PACKAGE"]=*name*(ɾ��������".XXXX"����)}. ���name��һ���Ե�ָ�Ĵ�����ô�õ���mod����������ӣ�
         hello.world==> {["hello"]={["world"]={XXXXXXX}}}��
4. ���ε���cbs��cb1(mod), cb2(mod),...��
5. ����ǰģ��Ļ�������Ϊmod,ͬʱ��package.loaded[name] = mod��




## ��������

### Attempt to Index a Boolean Value

��ʹ��require����lua�ļ�ʱ������lua�ļ�û�з���ֵ��Ĭ�Ϸ���boolean���͵�ֵ��true��ʾ����ģ��ɹ���false��ʾ����ģ��ʧ�ܡ�
    
