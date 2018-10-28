#! /bin/sh
warFile=$1
serverPort=$2
action=$3

stop_service(){
        echo –n “Stopping application”
        touch temp.text
        lsof -n -i TCP:$serverPort | awk '{print $2}' > temp.text
        pidToStop=`(sed '2q;d' temp.text)`> temp.text
        if [[ -n $pidToStop ]]
        then
        kill -9 $pidToStop
        echo "Congrats!! $serverPort  is stopped having pid $pidToStop."
        else
        echo "Sorry nothing running on $serverPort port"
        fi
    }

start_service(){
        echo –n “Starting application”
        nohup java -Dserver.port=$serverPort -jar $warFile & > /dev/null &
        echo "Congrats!! application is started on port $serverPort."
    }
    
is_running(){
        touch temp.text
        lsof -n -i TCP:$serverPort | awk '{print $2}' > temp.text
        pidToStop=`(sed '2q;d' temp.text)`> temp.text
        if [[ -n $pidToStop ]]
        then 
            return 0
        else
            return 1
        fi
        
}

case $action in
    start)
        if is_running;
            then
                echo "Already running on port $serverPort with pid $pidToStop"
                exit 1
            else
                echo "Starting application"
                start_service         
        fi
        ;;
    stop) 
        stop_service
        ;;
    restart)
       stop_service
       start_service
        ;;     
    *)
    echo "Usage: warFile port start|stop|restart"
    exit 1
    ;;
esac
