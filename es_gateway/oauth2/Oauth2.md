# OAuth2.0��֤����Ȩԭ��
[TOC]

OAuth��Open Authorization���ǿ�����Ȩ������������������û���Ȩ��ǰ���£��������û�����������洢�ĸ�����Ϣ��������Ȩ����Ҫ���û����������ṩ����������վ��OAuth�����û��ṩһ�����Ƹ���������վ��һ�����ƶ�Ӧ��һ���ض��ĵ�������ͬʱ������ֻ�����ض���ʱ���ڷ����ض�����Դ��

�������ĺô��ǲ���Ҫ�Ե����������û��������룬����������Ȩ��Χ����Ч�ڣ���ֹһ����վ�ϵ��û������뱻�ƽ��������ʹ����ͬ�û������������վ����й¶�� 

#### ���ʶ���
- **Third-party Application**: ������Ӧ�ó��򣬱��ĳ�Ϊ��client����

- **HTTP Service**��HTTP�����ṩ�̣����ļ�ơ������ṩ�̡���

- **Resource  Owner**����Դ�����ߣ����ĳ�Ϊ���û�����

- **User Agent**���û���������ָ�����������

- **Authorization  Server**����֤�������������ṩ��ר������������֤�ķ�������

- **Resource Server**����Դ�������������ṩ�̴���û����ɵ���Դ�ķ�������������֤������������ͬһ̨��������Ҳ�����ǲ�̨ͬ��

**OAuth���˼·**��OAuth�ڡ��ͻ��ˡ��͡������ṩ�̡�֮��������һ����Ȩ�㣨authorization layer�������ͻ��ˡ�����ֱ�ӵ�¼�������ṩ�̡���ֻ�ܵ�¼��Ȩ�㣬�Դ˽��û���ͻ������ֿ������ͻ��ˡ���¼��Ȩ���ȡ���ƣ��û������ڵ�¼ʱָ����Ȩ�����Ƶ�Ȩ�޷�Χ����Ч�ڡ�

##OAuth��������ͼ

```mermaid
sequenceDiagram
  Client->>+Resource Owner:(A) Authorization Request
  note over Client,Resource Owner: ��Ȩ
  Resource Owner-->>-Client:(B) Authorization Grant
  
  Client->>+Authroization  Server:(C) Authorizatioin Grant
  note over Client,Authroization  Server: ��ȡ��������
  Authroization  Server-->>-Client:(D) Access Token
  Client->>+Resource Server: (E) Access Token
  Resource Server-->>-Client:(F) Protected Resource
```

(A) �û��򿪿ͻ����Ժ� �ͻ���Ҫ���û�������Ȩ��

(B*) �û�ͬ�������Ȩ ��[�û���β��ܸ���ͻ�����Ȩ]

(C) �ͻ���ʹ����һ����õ���Ȩ������֤�������������ƣ�

(D) ��֤�������Կͻ��˽�����֤��ȷ�� ����ͬ�ⷢ�����ƣ�

(E) �ͻ���ʹ����������Դ��������������Դ ��

(F) ��Դ������ȷ����������ͬ����ͻ��˿�����Դ��

## �ͻ��˵���Ȩģʽ

�ͻ��˱���õ��û�����Ȩ��authorization  grant�������ܹ��������(access token)��OAuth������������Ȩ��������Ȩ�� ģʽ ����ģʽ ������ģʽ���ͻ���ģʽ��

###  1����Ȩ��ģʽ��authorization code��

��Ȩ��ģʽ���ǹ��������������������ܵ���Ȩģʽ���ص���ͨ�����ͻ��ˡ��ĺ�̨������ �롰�����ṩ�̡�����֤������������ 

![oauth_01](../img/oauth_01.png)

(A) �û����ʿͻ��� �����߽�ǰ�ߵ�����֤���������˲����з��������а������²���

- response_type: ��ʾ��Ȩ���ͣ�������˴�Ϊ�̶�ֵΪ"code"
- client_id����ʾ�ͻ���ID������ѡ��
- redirect_uri����ʾ�ض���URI����ѡ�� ��
- scope������Ȩ�޵ķ�Χ����ѡ�� ��
- state����ʶ�ͻ��˵ĵ�ǰ״̬������ָ������ֵ����֤�������� ԭ�ⲻ�� �ط������ֵ��

```http
GET  /authorize?response_type=code&client_id=s4BhdRkj&state=s12xt&redirect_uri=https%3A%2F%2F//client.example.com%2F HTTP/1.1
Host: sesver.example.com
```

(B) �û�ѡ�� �Ƿ����ͻ�����Ȩ��

(C) �����û�������Ȩ����֤���������û�����ͻ�������ָ��ġ��ض���URL(redirect  url)����ͬʱ������Ȩ�룻��Ȩ��������Ӧ�ͻ��˵�URI�а������²��� ��

- code����ʾ��Ȩ�룬���������������ں̣ܶ�ͨ��Ϊ10���ӣ��ͻ���ֻ��ʹ�� ����һ�Σ�����ᱻ��Ȩ�������ܾ���������ͻ��� ID�� �ض���URI��һһ��Ӧ��ϵ��
- state����� �ͻ��˵� �����а��������������֤�������Ļ�ӦҲ���� һģһ���ĵİ������ ������  

```http
HTTP/1.1 302 Found
location��https://client.example.com?code=Spl0xZTRYbsdf68Mg8&state=s12xt
```

(D) �ͻ����յ���Ȩ�룬�������ȵġ��ض���URL��������֤�������������� ����һ�����ڿͻ��˵ĺ�̨��������ɵģ����û����ɼ����ͻ�������֤�������������Ƶ������а��� ���²�����

- grant_type����ʾʹ�õ���Ȩģʽ���˴���ֵΪ��authorization_code������ѡ�
- code����ʾ��һ����ȡ����Ȩ�룬��ѡ�
- redirect_uri����ʾ�ض���URI����ѡ��ұ�����A�����е� ֵ����һ�£�
- client_id����ʾ�ͻ��� ID����ѡ�

```http
POST /token HTTP/1.1
Host:  server.example.com
Authorization: Basic  caZzCaGRSa3F0Mzpnhs2JM
Content-Type: application/x-wwww.form-urlencoded

grant_type=authorization_code&code=Spl0xZTRYbsdf68Mg8&redirect_uri=https%3A%2F%2F//client.example.com%2F&client_id=s4BhdRkj
```

(E) ��֤�������˶��� ��Ȩ��� �ض���URL��ȷ���������ͻ��˷��ͷ�������(access  token)�͸�������(refresh token) ����֤���������ص�HTTP��Ӧ��Ӧ����һ�²�����

- access_token����ʾ�������ƣ���ѡ�
- token_type����ʾ�������� ����Сд�����У���ѡ�� ��������bearer���ͻ�mac���ͣ�
- expires_in����ʾ����ʱ�� ����λΪ�룬���ò���ʡ�ԣ�������������ʽ���ù���ʱ�䣻
- refresh_token����ʾ�������ƣ�������ȡ��һ�εķ������ƣ���ѡ�
- scope����ʾȨ�޷�Χ�������ͻ�������ķ�Χһ�£������ʡ�ԣ�

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

###  2����ģʽ��implicit grant type��

��ģʽ��ͨ��������Ӧ�ó����������ֱ���������������֤�������������ƣ���������ȡ��Ȩ�롱������裬��˶����������в��������������ɣ����ƶԷ������ǿɼ��ģ��ҿͻ��˲���Ҫ ��֤�� 

![oauth_02](../img/oauth_02.png)

(A) �ͻ��˽��û�������֤ ���������ͻ��˷���HTTP����˵Ҫ�����Ĳ�����

- response_type����ʾ ��Ȩ���ͣ��˴���ֵ�̶� Ϊ"token"�������� ��
- client_id����ʾ�ͻ���ID����ѡ�� ��
- redirect_uri����ʾ�ض���URI����ѡ�
- scope����ʾȨ�޷�Χ����ѡ�
- state����ʾ�ͻ��˵ĵ�ǰ״̬������ָ������ֵ����֤��������ԭ�ⲻ���ķ��أ�

```http
GET /authorize?responses_type=tokan&client_id=s4BhdRkj&state=s12xt&redirect_uri=https%3A%2F%2F//client.example.com%2F HTTP/1.1
Host:server.example.com
```

(B) �û������Ƿ����ͻ�����Ȩ ��

(C) �����û�������Ȩ ����֤ ������ ���û�����ͻ���ָ���ġ��ض���URI��������URI�� Hash���ְ����� �������ƣ���֤��������ͻ��� ��Ӧ����а����������£�

- access_token����ʾ�������ƣ���ѡ�
- token_type����ʾ���� ���� ����ֵ��Сд �����У���ѡ�
- expires_in����ʾ����ʱ�䣬��λΪ�� �����ʡ�Ըò���������������ʽ���ù���ʱ�䣻
- scope����ʾȨ�޷�Χ�������ͻ�������ķ�Χһ�� ���������ʡ�ԣ�
- state������ͻ��� �������а������ ���� ����֤ �������Ļ�ӦҲ����һģһ���ĵķ��أ�

```http
HTTP/1.1 302  Found
Location��http://client.example.com#access_token=2YotnFZFEjr1zCsicMWpAA&token_type=example&expire_in=3600

������������֤��������HTTPͷ��Locationָ��������ض������ַ�������ַ��Hash���� ���������ơ���D���У��ͻ��˻����Locationָ������ַ����hash���ֲ��ᷢ�͡���E���У������ṩ�̵���Դ���������͹����Ĵ��룬����ȡhash�е����ơ� 
```

(D) �ͻ�������Դ�����������������в�������һ���յ���hashֵ��

(E) ��Դ����������һ����ҳ�����а����Ĵ�����Ի�ȡHashֵ�е����ƣ�

(F) �����ִ����һ����õĽű�����ȡ�����ƣ�

(G) ����������Ʒ��͸��ͻ��ˣ�

###  3������ģʽ��resource owner password credentials��

![oauth_03](../img/oauth_03.png)

����ģʽ��Resource  Owner  Password Credentials  Grant�����û���ͻ��� �ṩ�Լ� ���û��������롣�ͻ���ʹ����Щ��Ϣ��������ṩ����Ҫ��Ȩ�������� ģʽ�� ���û�������Լ���������ͻ��ˣ�����==�ͻ��˲��ô洢����== ������ģʽͨ�������û��Կͻ��˸߶����ε�����£����磺�ͻ����� ����ϵͳ��һ���֣�������һ�������Ĺ�˾��Ʒ������֤������ֻ�������� ��Ȩģʽ�޷�ִ�е� ����£����ܿ���ʹ������ģʽ��

(A) �û���ͻ����ṩ�Լ����û��������룻

(B) �ͻ��˽��û��������뷢�͸���֤��������������������ƣ��ͻ�������֤��������������Ĳ�����

- grant_type����ʾ��Ȩ���ͣ�Ϊ�̶�ֵ��passwor���������
- username����ʾ�û����������
- password����ʾ�û����� �������
- scope����ʾȨ�޷�Χ����ѡ�� ��

```http
POST /token  HTTP/1.1
Host: server.example.com
Authorization: Basic  caZzCaGRSa3F0Mzpnhs2JM
Content-Type: application/x-wwww.form-urlencoded

grant_type=passowrd&username=exam&password=examppwd
```

(C) ��֤������ȷ���������ͻ����ṩ�������ƣ���֤��������������ͻ��˷��ͷ������ƣ���Ӧ������£�

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

###  4���ͻ���ģʽ��client credentials��

![oauth_04](../img/oauth_04.png)

�ͻ���ģʽ(Client Credentials Grant)ָ�ͻ������Լ������壬���������û������壬������ṩ�̽�����֤���ϸ���˵���ͻ���ģʽ��������OAuth�����Ҫ��������⡣����ģʽ�У��û�ֱ���� �ͻ���ע�ᣬ�ͻ������Լ�������Ҫ������ṩ���ṩ������ʵ��������Ȩ���⡣

(A) �ͻ�������֤���������������֤����Ҫ��һ���������ƣ��ͻ��˷�������Ĳ�������֤������ ������ĳ�ַ�ʽ��֤�ͻ�����ݣ�

- grant_type����ʾ��Ȩ���ͣ��˴���ֵΪ��client_credentials������ѡ�
- scope����ʾȨ�޷�Χ ����ѡ�

```http
POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic  caZzCaGRSa3F0Mzpnhs2JM
Content-Type: application/x-wwww.form-urlencoded


grant_type=client_credentials
```

(B) ��֤������ȷ���������ͻ����ṩ�������ƣ���֤����������Ӧ���£�

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

## ��������

����û����ʵ�ʱ�򣬿ͻ��˵ķ��������Ѿ����ڣ�����Ҫʹ�á��������� ������һ���µķ������ơ��ͻ��˷��͸������Ƶ����󣬰��� һ�²�����

-  grant_type����ʾ��Ȩģʽ���˴���ֵ �̶� Ϊ��refresh_token���������
-  refresh_token����ʾ��ǰ�յ��ĸ������ƣ���ѡ�
-  scope����ʾ������Ȩ�ķ�Χ�������Գ�����һ������ķ�Χ�����ʡ�Ըò��������ʾ����һ��һ�£�

```http
POST /token HTTP/1.1
Host: server.example.com
Authorization: Basic  caZzCaGRSa3F0Mzpnhs2JM
Content-Type: application/x-wwww.form-urlencoded


grant_type=refresh_token&refresh_token=tGzv3JOKF0XG5Qx2TlKWIA
```

���������Ӧ�������

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





##����GitHub��OAuth2.0ʵ��

�û���¼��������վ(�ͻ���)��Ҫͨ��GitHub�˺�(�����ṩ�� )ȥ��¼��Ϊ����Ҫ�����ʹ��GitHub��¼����ť�������Ϳ����� OAuth2.0��Ȩ��֤�Ĺ��� ����Ҫ�������£�

1. ��վ(�ͻ��� )��GitHub(�����ṩ��)֮���Э��

   github����û���Ȩ�� ���з��࣬���磺���ֿ���ϢȨ�ޡ�д�ֿ���ϢȨ�� �����û���ϢȨ�ޡ�д�û���ϢȨ�޵ȡ�����Ҫ�û� ��Ϣ��������ʱ��ע��Ҫ��ȡ�û�����ЩȨ�ޣ���������ʱ��д��վ��������githubֻ�������������ȡ�û���Ϣ������վ��github��ɹ�ʶ��github��������client_id��client_secret������վ	�б��桿

   ```http
   POST /oauth2 HTTP/1.1

   appname="Hello World App"&redirect_uri=http%3A%2F%2Fmy-website.com%2F
   ```

   ���ؽ�����£�

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

2. �û���GitHub֮���Э��

   ��վ������������󣬴�ʱ������һ���û���Ȩ�Ľ���

   ```http
   // �û���¼ github��Э��
   GET https://github.com/login/oauth/authorize

   // Э��ƾ֤
   params = {
     client_id: "xxxx",
     redirect_uri: "http://my-website.com"
   }
   ```

   ���û�������վҪ��Ȩ��̫�಻ͬ�⣬������ֱ�ӽ��� �����û����ȷ��ͬ����Ȩ����ҳ�����ת����Ԥ���趨�� `redirect_uri` ������һ����Ȩ�� code��

   ```http
   // Э�̳ɹ�����Ÿ����µ� code
   Location: http://my-website.com?code=xxx
   ```

3. ��ȡ��������

   ����ͨ����Ȩ�룬github���޷�ȷ�Ϸ����ߵ�����ǲ����û��Լ�����Ҫ��ȡ���� ����

   ```http
   // ��վ�� github ֮���Э��
   POST https://github.com/login/oauth/access_token

   //Э��ƾ֤���� github ���û��ǵ��º� github �����ҵ���Ʊ
   params = {
     code: "xxx",
     client_id: "xxx",
     client_secret: "xxx",
     redirect_uri: "http://my-website.com"
   }
   ```

     �������� �������ܹ��õ���������

   ```json
   {
     access_token: "e72e16c7e42f292c6912e7710c838347ae178b4a"
     scope: "user,gist"
     token_type: "bearer",
     refresh_token: "xxxx"
   }
   ```

4. ��վͨ���������Ʒ���github�ϵ��û���Ϣ

   ```http
   // �����û�����
   GET https://api.github.com/user?access_token=e72e16c7e42f292c6912e7710c838347ae178b4a
   ```

   github���ܷ��ص��û���Ϣ����

   ```json
    {
     username: "barretlee",
     email: "barret.china@gmail.com"
   }
   ```










## ����ULOG API GATEWAY��OAuth2.0ʵ��

```mermaid
sequenceDiagram
  ClientApp ->>+ Login:(1) Redirect final user
  Login ->>+ Authorization: (2)Login ��(3) Authorize
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

















[1]: OAuth1.0����Ϊû�ж�redirect_uri�ص���ַ����У�飬����һ���Ự�̻�������©������ȷʹ��OAuth��state����Ԥ��CSRF������(https://www.zhihu.com/question/19781476)