# Run the servers.

# Pluto.
Thread.new {system("sudo -u clarus bash -c \"eval \\`opam config env\\`; pluto.native 8000 /home/clarus/www/coq-blog/blog\"")}

# Nginx.
Thread.new {system(["nginx", "-g", "daemon off;"])}
