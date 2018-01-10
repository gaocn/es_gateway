# OAuth2.0认证和授权原理
[TOC]

OAuth（Open Authorization）是开放授权，允许第三方服务在用户授权的前提下，访问在用户服务商那里存储的各种信息。这种授权不需要将用户名和密码提供给第三方网站，OAuth允许用户提供一个令牌给第三方网站，一个令牌对应个一个特定的第三服务，同时该令牌只能在特定的时间内访问特定的资源。

这样做的好处是不需要对第三方输入用户名和密码，可以限制授权范围和有效期，防止一个网站上的用户名密码被破解后其他所使用相同用户名和密码的网站数据泄露。 

#### 名词定义
- **Third-party Application**: 第三方应用程序，本文称为“client”；

- **HTTP Service**：HTTP服务提供商，本文简称“服务提供商”；

- **Resource  Owner**：资源所有者，本文称为“用户”；

- **User Agent**：用户代理，本文指的是浏览器；

- **Authorization  Server**：认证服务器，服务提供商专门用来处理认证的服务器；

- **Resource Server**：资源服务器，服务提供商存放用户生成的资源的服务器，它与认证服务器可以是同一台服务器，也可以是不同台；

**OAuth设计思路**：OAuth在“客户端”和“服务提供商”之间设置了一个授权层（authorization layer），“客户端”不能直接登录“服务提供商”，只能登录授权层，以此将用户与客户端区分开。“客户端”登录授权层获取令牌，用户可以在登录时指定授权层令牌的权限范围和有效期。

##OAuth运行流程图

```mermaid
sequenceDiagram
  Client->>+Resource Owner:(A) Authorization Request
  note over Client,Resource Owner: 授权
  Resource Owner-->>-Client:(B) Authorization Grant
  
  Client->>+Authroization  Server:(C) Authorizatioin Grant
  note over Client,Authroization  Server: 获取访问令牌
  Authroization  Server-->>-Client:(D) Access Token
  Client->>+Resource Server: (E) Access Token
  Resource Server-->>-Client:(F) Protected Resource
```

(A) 用户打开客户端以后， 客户端要求用户给予授权；

(B*) 用户同意给予授权 ；[用户如何才能给予客户端授权]

(C) 客户端使用上一步获得的授权，向认证服务器申请令牌；

(D) 认证服务器对客户端进行认证后，确认 无误，同意发放令牌；

(E) 客户端使用令牌向资源服务器是申请资源 ；

(F) 资源服务器确认令牌无误，同意向客户端开放资源；

## 客户端的授权模式

客户端必须得到用户的授权（authorization  grant），才能够获得令牌(access token)。OAuth定义了四种授权方法：授权码 模式 、简化模式 、密码模式、客户端模式。

###  1、授权码模式（authorization code）

授权码模式化是功能最完整、流程最严密的授权模式。特点是通过“客户端”的后台服务器 与“服务提供商”的认证服务器交互。 

![oauth_01](../img/oauth_01.png)

(A) 用户访问客户端 ，后者将前者导向认证服务器；此步骤中发的请求中包含以下参数

- response_type: 表示授权类型，必须项，此处为固定值为"code"
- client_id：表示客户端ID，必须选；
- redirect_uri：表示重定向URI，可选项 ；
- scope：申请权限的范围，可选项 ；
- state：辨识客户端的当前状态，可以指定任意值，认证服务器会 原封不动 地返回这个值；

```http
GET  /authorize?response_type=code&client_id=s4BhdRkj&state=s12xt&redirect_uri=https%3A%2F%2F//client.example.com%2F HTTP/1.1
Host: sesver.example.com
```

(B) 用户选择 是否给予客户端授权；

(C) 假设用户给予授权，认证服务器将用户导向客户端事先指向的“重定向URL(redirect  url)”，同时附上授权码；授权服务器响应客户端的URI中包含以下参数 ：

- code：表示授权码，必须项；该码的有限期很短，通常为10分钟，客户端只能使用 改码一次，否则会被授权服务器拒绝。该码与客户端 ID和 重定向URI是一一对应关系；
- state：如果 客户端的 请求中包含这个参数，认证服务器的回应也必须 一模一样的的包含这个 参数；  

```http
HTTP/1.1 302 Found
location：https://client.example.com?code=Spl0xZTRYbsdf68Mg8&state=s12xt
```

(D) 客户端收到授权码，附上早先的“重定向URL”，向认证服务器申请令牌 。这一步是在客户端的后台服务器完成的，对用户不可见；客户端向认证服务器申请令牌的请求中包含 如下参数：

- grant_type：表示使用的授权模式，此处的值为“authorization_code”，必选项；
- code：表示上一步获取的授权码，必选项；
- redirect_uri：表示重定向URI，必选项，且必须与A步骤中的 值保持一致；
- client_id：表示客户端 ID，必选项；

```http
POST /token HTTP/1.1
Host:  server.example.com
Authorization: Basic  caZzCaGRSa3F0Mzpnhs2JM
Content-Type: application/x-wwww.form-urlencoded

grant_type=authorization_code&code=Spl0xZTRYbsdf68Mg8&redirect_uri=https%3A%2F%2F//client.example.com%2F&client_id=s4BhdRkj
```

(E) 认证服务器核对了 授权码和 重定向URL，确认无误后，向客户端发送访问令牌(access  token)和更新令牌(refresh token) ；认证服务器返回的HTTP响应中应包含一下参数：

- access_token：表示访问令牌，必选项；
- token_type：表示令牌类型 ，大小写不敏感，必选项 ，可以是bearer类型或mac类型；
- expires_in：表示过期时间 ，单位为秒，若该参数省略，必须有其他方式设置过期时间；
- refresh_token：表示更新令牌，用来获取下一次的访问令牌，可选项；
- scope：表示权限范围，如果与客户端申请的范围一致，此项可省略；

```http
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Cache-Control: no-store
Pragma: no-cache

{
  "access_token":"2YotnFZFEjr1zCsicMWpAA",
  "token_type":"example",
  "expire_in":3600,
  "refresh_token":"tGzv3JOKF0XG5Qx2TlKWIA",
  "example_parameter":"example_value"
}
```

###  2、简化模式（implicit grant type）

简化模式不通过第三方应用程序服务器，直接在浏览器中向认证服务器申请令牌，跳过“获取授权码”这个步骤，因此而得名。所有步骤在浏览器中完成，令牌对访问者是可见的，且客户端不需要 认证。 

![oauth_02](../img/oauth_02.png)

(A) 客户端将用户导向认证 服务器；客户端发送HTTP请求说要包含的参数：

- response_type：表示 授权类型，此处的值固定 为"token"，必须项 ；
- client_id：表示客户端ID，必选项 ；
- redirect_uri：表示重定向URI，可选项；
- scope：表示权限范围，可选项；
- state：表示客户端的当前状态，可以指定任意值，认证服务器会原封不动的返回；

```http
GET /authorize?responses_type=tokan&client_id=s4BhdRkj&state=s12xt&redirect_uri=https%3A%2F%2F//client.example.com%2F HTTP/1.1
Host:server.example.com
```

(B) 用户决定是否给予客户端授权 ；

(C) 假设用户基于授权 ，认证 服务器 将用户导向客户端指定的“重定向URI”，并在URI的 Hash部分包含了 访问令牌；认证服务器向客户端 响应结果中包含参数如下：

- access_token：表示访问令牌，必选项；
- token_type：表示令牌 类型 ，该值大小写 不敏感，必选项；
- expires_in：表示过期时间，单位为秒 ，如果省略该参数，必须其他方式设置过期时间；
- scope：表示权限范围，如果与客户单申请的范围一致 ，此项可以省略；
- state：如果客户端 的请求中包含这个 参数 ，认证 服务器的回应也必须一模一样的的返回；

```http
HTTP/1.1 302  Found
Location：http://client.example.com#access_token=2YotnFZFEjr1zCsicMWpAA&token_type=example&expire_in=3600

上面例子中认证服务器用HTTP头部Location指定浏览器重定向的网址，这个网址的Hash部分 包含了令牌。在D步中，客户端会访问Location指定的网址，但hash部分不会发送。在E步中，服务提供商的资源服务器发送过来的代码，会提取hash中的令牌。 
```

(D) 客户端向资源服务器发出请求，其中不包括上一步收到的hash值；

(E) 资源服务器返回一个网页，其中包含的代码可以获取Hash值中的令牌；

(F) 浏览器执行上一步获得的脚本，提取出令牌；

(G) 浏览器将令牌发送给客户端；

###  3、密码模式（resource owner password credentials）

![oauth_03](../img/oauth_03.png)

密码模式（Resource  Owner  Password Credentials  Grant），用户向客户端 提供自己 的用户名和密码。客户端使用这些信息，向服务提供商索要授权。在这种 模式中 ，用户必须把自己的密码给客户端，但是==客户端不得存储密码== 。密码模式通常用在用户对客户端高度信任的情况下，比如：客户端是 操作系统的一部分，或者有一个组名的公司出品。而认证服务器只有在其他 授权模式无法执行的 情况下，才能考虑使用这种模式。

(A) 用户向客户端提供自己的用户名和密码；

(B) 客户端将用户名和密码发送给认证服务器，向后者请求令牌；客户端向认证服务器发送请求的参数：

- grant_type：表示授权类型，为固定值“passwor”，必须项；
- username：表示用户名，必须项；
- password：表示用户密码 ，必须项；
- scope：表示权限范围，可选项 ；

```http
POST /token  HTTP/1.1
Host: server.example.com
Authorization: Basic  caZzCaGRSa3F0Mzpnhs2JM
Content-Type: application/x-wwww.form-urlencoded

grant_type=passowrd&username=exam&password=examppwd
```

(C) 认证服务器确认无误后，向客户端提供访问令牌；认证服务器服务器向客户端发送访问令牌，响应结果如下：

```http
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Cache-Control: no-store
Pragma: no-cache

{
  "access_token":"2YotnFZFEjr1zCsicMWpAA",
  "token_type":"example",
  "expire_in":3600,
  "refresh_token":"tGzv3JOKF0XG5Qx2TlKWIA",
  "example_parameter":"example_value"
}
```

###  4、客户端模式（client credentials）

![oauth_04](../img/oauth_04.png)

客户端模式(Client Credentials Grant)指客户端以自己的名义，而不是以用户的名义，向服务提供商进行认证。严格来说，客户端模式并不属于OAuth框架所要解决的问题。这种模式中，用户直接向 客户端注册，客户端以自己的名义要求服务提供商提供服务，其实不存在授权问题。

(A) 客户端向认证服务器进行身份认证，并要求一个访问令牌；客户端发送请求的参数，认证服务器 必须以某种方式验证客户端身份：

- grant_type：表示授权类型，此处的值为“client_credentials”，必选项；
- scope：表示权限范围 ，可选项；

```http
POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic  caZzCaGRSa3F0Mzpnhs2JM
Content-Type: application/x-wwww.form-urlencoded


grant_type=client_credentials
```

(B) 认证服务器确认无误后，向客户端提供访问令牌；认证服务器的响应如下：

```http
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Cache-Control: no-store
Pragma: no-cache

{
  "access_token":"2YotnFZFEjr1zCsicMWpAA",
  "token_type":"example",
  "expire_in":3600,
  "refresh_token":"tGzv3JOKF0XG5Qx2TlKWIA",
  "example_parameter":"example_value"
}
```

## 更新令牌

如果用户访问的时候，客户端的访问令牌已经过期，则需要使用“更新令牌 ”申请一个新的访问令牌。客户端发送更新令牌的请求，包含 一下参数：

-  grant_type：表示授权模式，此处的值 固定 为“refresh_token”，必须项；
-  refresh_token：表示早前收到的更新令牌，必选项；
-  scope：表示申请授权的范围，不可以超过上一次申请的范围，如果省略该参数，则表示与上一次一致；

```http
POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic  caZzCaGRSa3F0Mzpnhs2JM
Content-Type: application/x-wwww.form-urlencoded


grant_type=refresh_token&refresh_token=tGzv3JOKF0XG5Qx2TlKWIA
```

该请求的响应结果如下

```http
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Cache-Control: no-store
Pragma: no-cache

{
  "access_token":"2YotnFZFEjr1zCsicMWpAA",
  "token_type":"example",
  "expire_in":3600,
  "refresh_token":"BGzv3JOTgBNdRtsQx2TlKWIA",
  "example_parameter":"example_value"
}
```





##范例GitHub上OAuth2.0实现

用户登录第三方网站(客户端)想要通过GitHub账号(服务提供商 )去登录，为此需要点击“使用GitHub登录”按钮，这样就开启了 OAuth2.0授权认证的过程 ，主要步骤如下：

1. 网站(客户端 )与GitHub(服务提供商)之间的协商

   github会对用户的权限 进行分类，比如：读仓库信息权限、写仓库信息权限 、读用户信息权限、写用户信息权限等。若想要用户 信息，在申请时标注需要获取用户的哪些权限，并在申请时填写网站的域名，github只允许这个域名获取用户信息；在网站和github达成共识后，github会生产：client_id、client_secret【在网站	中保存】

   ```http
   POST /oauth2 HTTP/1.1

   appname="Hello World App"&redirect_uri=http%3A%2F%2Fmy-website.com%2F
   ```

   返回结果如下：

   ```json
   {
       "consumer_id": "a0977612-bd8c-4c6f-ccea-24743112847f",
       "client_id": "318f98be1453427bc2937fceab9811bd",
       "id": "7ce2f90c-3ec5-4d93-cd62-3d42eb6f9b64",
       "appname": "Hello World App",
       "created_at": 1435783376000,
       "redirect_uri": "http://my-website.com/",
       "client_secret": "efbc9e1f2bcc4968c988ef5b839dd5a4"
   }
   ```

2. 用户与GitHub之间的协商

   网站发送下面请求后，此时会跳出一个用户授权的界面

   ```http
   // 用户登录 github，协商
   GET https://github.com/login/oauth/authorize

   // 协商凭证
   params = {
     client_id: "xxxx",
     redirect_uri: "http://my-website.com"
   }
   ```

   若用户觉得网站要的权限太多不同意，则请求直接结束 ；若用户点击确认同意授权，则页面会跳转到我预先设定的 `redirect_uri` 并附带一个授权码 code。

   ```http
   // 协商成功后带着盖了章的 code
   Location: http://my-website.com?code=xxx
   ```

3. 获取访问令牌

   仅仅通过授权码，github是无法确认访问者的身份是不是用户自己，需要获取访问 令牌

   ```http
   // 网站和 github 之间的协商
   POST https://github.com/login/oauth/access_token

   //协商凭证包括 github 给用户盖的章和 github 发给我的门票
   params = {
     code: "xxx",
     client_id: "xxx",
     client_secret: "xxx",
     redirect_uri: "http://my-website.com"
   }
   ```

     发送上述 请求后就能够得到访问令牌

   ```json
   {
     access_token: "e72e16c7e42f292c6912e7710c838347ae178b4a"
     scope: "user,gist"
     token_type: "bearer",
     refresh_token: "xxxx"
   }
   ```

4. 网站通过访问令牌访问github上的用户信息

   ```http
   // 访问用户数据
   GET https://api.github.com/user?access_token=e72e16c7e42f292c6912e7710c838347ae178b4a
   ```

   github可能返回的用户信息如下

   ```json
    {
     username: "barretlee",
     email: "barret.china@gmail.com"
   }
   ```










## 范例ULOG API GATEWAY的OAuth2.0实现

```mermaid
sequenceDiagram
  ClientApp ->>+ Login:(1) Redirect final user
  Login ->>+ Authorization: (2)Login 、(3) Authorize
  note over Login,Authorization: Web Applicaton Frontend
  note over WebApp Backend: Web Application Backend
  Authorization ->>+ WebApp Backend: (4) POST
  note over API GATEWAY: Applicatons Codes Tokens
  WebApp Backend ->>+ API GATEWAY: (5) POST:Authorization Flow
  API GATEWAY -->>- WebApp Backend: (6) Code and Redirect URI
  WebApp Backend -->>- ClientApp: (7) Redirect user to  URI
  ClientApp ->> API GATEWAY:  (8) Retrieve Access Token(If Authorization Code flow)
  ClientApp ->> API GATEWAY:  (9) Make Request with Access Token
  ClientApp -->> API GATEWAY: (10) When Access Token expires, refresh the Token
```

















[1]: OAuth1.0中因为没有对redirect_uri回调地址进行校验，存在一个会话固话攻击的漏洞，正确使用OAuth的state参数预防CSRF攻击。(https://www.zhihu.com/question/19781476)