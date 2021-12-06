#!/bin/bash

# 每个es节点的最大内存，单位m
es_max_mem=128

# es 节点数量
es_node_amount=3

function install_ES()
{
    echo -e "现在安装ES .....\n"
    echo -e "现在下载ES .....\n"
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.13.0-linux-x86_64.tar.gz

    initial_master_nodes=""
    for ((i=1; i<=$1; i++))
    do
        initial_master_nodes=$initial_master_nodes'"my_node_'$i'"'
        if [ $i != $1 ] ; then
            initial_master_nodes=$initial_master_nodes', '
        fi
    done

    for ((i=1; i<=$1; i++))
    do
        node_dir=es_node$i
        tar xvf elasticsearch-7.13.0-linux-x86_64.tar.gz
        mv elasticsearch-7.13.0 $node_dir
        cd $node_dir
        echo -e '\n' >> config/elasticsearch.yml
        echo 'cluster.name: my_app' >> config/elasticsearch.yml
        echo "node.name: my_node_$i" >> config/elasticsearch.yml
        echo 'path.data: ./data' >> config/elasticsearch.yml
        echo 'path.logs: ./logs' >> config/elasticsearch.yml
        echo "http.port: 921$i" >> config/elasticsearch.yml
        echo "transport.port: 930$i" >> config/elasticsearch.yml
        echo 'network.host: 0.0.0.0' >> config/elasticsearch.yml
        # 所有节点都连接到9031这个节点上去
        echo 'discovery.seed_hosts: ["localhost:9301"]' >> config/elasticsearch.yml
        echo 'cluster.initial_master_nodes: ['$initial_master_nodes']' >> config/elasticsearch.yml

        echo -e '\n' >> config/jvm.options
        echo "-Xms${es_max_mem}m" >> config/jvm.options
        echo "-Xmx${es_max_mem}m" >> config/jvm.options

        touch start.sh
        echo 'echo "现在启动ES'$i'....."' >> start.sh
        echo "./bin/elasticsearch -d" >> start.sh
        cd ..
    done
}

function install_kibana()
{
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
    cd ..
}

function install_cerebro()
{
        echo -e "现在安装cerebro ......"
        wget https://github.com/lmenezes/cerebro/releases/download/v0.9.4/cerebro-0.9.4.tgz
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
}

function create_start_shell()
{
    touch start_singleton_es.sh

    app_name="'"'{print $2}'"'"

    echo 'function kill_all_app_by_name()
{
        pid=`ps -ef | grep $1 | grep -v "grep" | awk -F" " '${app_name}'`
        for i in $pid; do
                kill -9 $i
        done
}

kill_all_app_by_name "kibana"
kill_all_app_by_name "cerebro"
kill_all_app_by_name "Elasticsearch"' >> start_singleton_es.sh

    for ((i=1; i<=$1; i++))
    do
        echo "cd es_node$i" >> start_singleton_es.sh
        echo "bash start.sh" >> start_singleton_es.sh
        echo "cd .." >> start_singleton_es.sh
    done

    echo "cd kibana" >> start_singleton_es.sh
    echo "bash start.sh" >> start_singleton_es.sh
    echo "cd .." >> start_singleton_es.sh

    echo "cd cerebro" >> start_singleton_es.sh
    echo "bash start.sh" >> start_singleton_es.sh
    echo "cd .." >> start_singleton_es.sh
}

function clean_all()
{
    rm elasticsearch-7.13.0-linux-x86_64.tar.gz
    rm kibana-7.13.0-linux-x86_64.tar.gz
    rm cerebro-0.9.4.tgz
    rm add_sysctl.sh
}

function set_system_config()
{
    echo 'echo "\nvm.max_map_count=262144" >> /etc/sysctl.conf' >> add_sysctl.sh
    echo 'sysctl -p' >> add_sysctl.sh
    chmod a+x add_sysctl.sh

    echo "现在进行操作系统层面的配置, 将执行sudo su 需要你输入密码....."
    sudo ./add_sysctl.sh
}

function kill_all_app_by_name()
{
        pid=`ps -ef | grep $1 | grep -v "grep" | awk -F" " '{print $2}'`
        for i in $pid; do
                kill -9 $i
        done
}

kill_all_app_by_name 'kibana'
kill_all_app_by_name 'cerebro'
kill_all_app_by_name 'Elasticsearch'

rm ES -rf
mkdir ES
cd ES

install_ES $es_node_amount
install_kibana
install_cerebro
set_system_config
create_start_shell $es_node_amount
clean_all
echo "安装已完成！请执行 bash start_singleton_es.sh 命令启动服务！"
