#!/bin/bash

# This script needs to be executed just once
if [ -f /setup_cache/$0.completed ] ; then
  echo "$0 `date` /setup_cache/$0.completed found, skipping run"
  exit 0
fi

# Wait for RabbitMQ startup
for (( ; ; )) ; do
  sleep 5
  rabbitmqctl -q node_health_check > /dev/null 2>&1
  if [ $? -eq 0 ] ; then
    echo "$0 `date` rabbitmq is now running"
    break
  else
    echo "$0 `date` waiting for rabbitmq startup"
  fi
done

# Execute RabbitMQ config commands here

# Create user
rabbitmqctl add_user cupidai TUtpjFYSK34xGx
rabbitmqctl set_user_tags cupidai administrator
rabbitmqctl set_permissions -p / cupidai ".*" ".*" ".*"
echo "$0 `date` user created"

# Create queue
rabbitmqadmin -u cupidai -p TUtpjFYSK34xGx declare queue name=minio_uploads durable=true
echo "$0 `date` queue created"

# Create binding
rabbitmqadmin -u cupidai -p TUtpjFYSK34xGx declare binding source="amq.direct" destination_type="queue" destination="minio_uploads" routing_key="minio_uploads"

# Create mark so script is not ran again
touch /setup_cache/$0.completed
