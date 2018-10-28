#! /bin/sh
warFile=$1
serverPort=$2
action=$3

remove_temp_file(){
    rm temp.text 
}

stop_service(){
        echo "Stopping application"
        touch temp.text
        lsof -n -i TCP:$serverPort | awk '{print $2}' > temp.text
        pidToStop=`(sed '2q;d' temp.text)`> temp.text
        if [[ -n $pidToStop ]]
        then
        kill -9 $pidToStop
        echo "Congrats!! application running on port $serverPort with pid $pidToStop is stopped."
        else
        echo "Sorry nothing running on $serverPort port"
        fi
        remove_temp_file
    }

start_service(){
        echo "Starting application"
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
        remove_temp_file
}

case $action in
    start)
        if is_running;
            then
                echo "Already running on port $serverPort with pid $pidToStop"
                exit 1
            else
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
