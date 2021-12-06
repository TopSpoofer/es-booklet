#!/bin/bash

mkdir ES
cd ES

echo -e "现在安装ES .....\n"
echo -e "现在下载ES .....\n"

wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.13.0-linux-x86_64.tar.gz
tar xvf elasticsearch-7.13.0-linux-x86_64.tar.gz
mv elasticsearch-7.13.0 es_node1
cd es_node1

echo -e '\n' >> config/elasticsearch.yml
echo 'cluster.name: my_app' >> config/elasticsearch.yml
echo 'node.name: my_node_1' >> config/elasticsearch.yml
echo 'path.data: ./data' >> config/elasticsearch.yml
echo 'path.logs: ./logs' >> config/elasticsearch.yml
echo 'http.port: 9211' >> config/elasticsearch.yml
echo 'network.host: 0.0.0.0' >> config/elasticsearch.yml
echo 'discovery.seed_hosts: ["localhost"]' >> config/elasticsearch.yml
echo 'cluster.initial_master_nodes: ["my_node_1"]' >> config/elasticsearch.yml

echo -e '\n' >> config/jvm.options
echo '-Xms1g' >> config/jvm.options
echo '-Xmx1g' >> config/jvm.options

touch start.sh
echo 'echo "现在启动ES....."' >> start.sh
echo "./bin/elasticsearch -d" >> start.sh


# 回到ES目录
cd ..
echo -e "现在安装Kibana ......\n"
wget https://artifacts.elastic.co/downloads/kibana/kibana-7.13.0-linux-x86_64.tar.gz
tar xvf kibana-7.13.0-linux-x86_64.tar.gz
mv kibana-7.13.0-linux-x86_64 kibana
cd kibana
echo -e '\nserver.host: "0.0.0.0"' >> config/kibana.yml
echo -e '\nelasticsearch.hosts: ["http://localhost:9211"]' >> config/kibana.yml

touch start.sh
echo 'echo "现在启动Kabana....."' >> start.sh
echo "./bin/kibana >> run.log 2>&1 &" >> start.sh


# 回到ES目录
cd ..
echo -e "现在安装cerebro ......"
wget https://github.91chifun.workers.dev/https://github.com//lmenezes/cerebro/releases/download/v0.9.4/cerebro-0.9.4.tgz
tar xvf cerebro-0.9.4.tgz
mv cerebro-0.9.4 cerebro
cd cerebro

sed -i 's/server.http.port = ${?CEREBRO_PORT}/server.http.port = 9800/g' conf/application.conf
echo -e '\nhosts = [
  {
    host = "http://localhost:9211"
    name = "my_app"
  }
]' >> conf/application.conf

touch start.sh
echo 'echo "现在启动cerebro....."' >> start.sh
echo "./bin/cerebro >> run.log 2>&1 &" >> start.sh

cd ..

touch start_singleton_es.sh

echo "cd es_node1" >> start_singleton_es.sh
echo "bash start.sh" >> start_singleton_es.sh
echo "cd .." >> start_singleton_es.sh

echo "cd kibana" >> start_singleton_es.sh
echo "bash start.sh" >> start_singleton_es.sh
echo "cd .." >> start_singleton_es.sh

echo "cd cerebro" >> start_singleton_es.sh
echo "bash start.sh" >> start_singleton_es.sh
echo "cd .." >> start_singleton_es.sh

rm elasticsearch-7.13.0-linux-x86_64.tar.gz
rm kibana-7.13.0-linux-x86_64.tar.gz
rm cerebro-0.9.4.tgz

echo 'echo "\nvm.max_map_count=262144" >> /etc/sysctl.conf' >> add_sysctl.sh
echo 'sysctl -p' >> add_sysctl.sh
chmod a+x add_sysctl.sh

echo "现在进行操作系统层面的配置, 将执行sudo su 需要你输入密码....."
sudo ./add_sysctl.sh

rm add_sysctl.sh
echo "安装已完成！请执行 bash start_singleton_es.sh 命令启动服务！"