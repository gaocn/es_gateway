--
-- User: ¸ßÎÄÎÄ
-- Date: 2017/12/6
-- Description:
--
--

gateway_conf = {
    nginx_bin_path = "/home/sm01/openresty-1.11.2/nginx/sbin",
    nginx_pid = "/home/sm01/openresty-1.11.2/nginx/logs/nginx.pid",
    conf_dir = "/home/sm01/openresty-1.11.2/",
    nginx_dir = "/home/sm01/openresty-1.11.2/nginx/",
    conf = "/home/sm01/openresty-1.11.2/nginx/conf/nginx.conf",
    nginx_search_paths = {
        "/home/sm01/openresty-1.11.2/nginx/sbin",
    },
    upstream_conf_path ="/home/sm01/openresty-1.11.2/nginx/conf/es_cluster_upstream.conf",
     system_cluster_map = ngx.shared.system_cluster_map,

     acl_table = ngx.shared.acl_table,
     init_config = "/home/sm01/openresty-1.11.2/config",
     acl_conf = "/home/sm01/openresty-1.11.2/nginx/conf/lua/api.acl"

}