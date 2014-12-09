# Run the servers.

# Pluto.
Thread.new {system("sudo -u clarus pluto.native 8000 /home/clarus/www/coq-blog")}

# Nginx.
Thread.new {system(["nginx", "-g", "daemon off;"])}
