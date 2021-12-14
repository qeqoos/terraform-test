#!/bin/bash

sudo yum update -y
sudo amazon-linux-extras install nginx1 -y

cat <<EOF > /usr/share/nginx/html/index.html
<html>

<h1>Hello from ${name} to ${object} and your sister and your cousin</h1>

We are going to win ${game} with %{ for hero in heroes ~} ${hero}, %{ endfor ~}

</html>
EOF

sudo systemctl start nginx.service

# result_first=1; 
# while [[ $result_first != 0 ]]; do 
#     if [[ `grep 'Nginx is fully up and running' /etc/nginx/access.log` ]];
#         then result_first=0;
#     else sleep 4;
#     fi;
# done

sudo systemctl enable nginx.service
