# Lua Web 框架Lapis
##Lapis简介

Lapis 是为 Lua 和 MoonScript 编写的 Web 框架。它建立在Nginx 发行的 OpenResty 之上Web 应用程序直接在 Nginx 内部运行。 Nginx 的事件循环允许您使用 OpenResty 提供的模块进行异步 HTTP 请求，数据库查询和其他请求。 Lua 的协程允许你编写在后台事件驱动的同步代码。除了提供Web框架，Lapis还提供了用于在不同配置环境中控制OpenResty的工具。最重要的是Openresty支持使用Lua编写WEB程序，来处理用户的请求。

Web 框架实现了 URL 路由器，HTML 模板，CSRF 和会话支持，PostgreSQL 或 MySQL 支持的主动记录系统，用于处理 model 和开发网站所需的一些其他有用的功能。

