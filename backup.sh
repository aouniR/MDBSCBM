#!/bin/bash
source mongo.env
source minio.env

#Backup dir
BACKUP_DIR="/backup"

for i in "${!MONGODB_HOSTS[@]}"; do 
    MONGODB_HOST="${MONGODB_HOSTS[$i]}"
    MINIO_HOST="${MINIO_HOSTS[$i]}"

    mongodump --host $MONGODB_HOST --port $MONGODB_PORT --username $MONGODB_USERNAME --password $MONGODB_PASSWORD --out $BACKUP_DIR
    mc alias set $MINIO_HOST http://$MINIO_HOST:9000 $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
    mc cp -r $BACKUP_DIR $MINIO_HOST/$BUCKET_NAME
done
