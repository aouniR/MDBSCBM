# MongoDB Shard Cluster backed up with MinIO

This task use to show how to deploy and scale a shard MongoDB Cluster backed up with MinIO, each shard cluster contains one replica set of 3 MongoDB instances, one primary and two secondaries, and MinIO instance for backup.

In this infrastructure, there's 3 datacenters each denoted by the label "datacenter={SAN/LAS/POW}, The SAN datacenter configured as config server and the {LAS/POW} as the shard replicaset.

The back up service will be automatically launched by a cron service from a bash container running on the ConfigSV cluster, the SAN datacenter.

 ![Application infrastructure](diag.png)


## Installation Steps

### Create docker manager node

        docker swarm init --listen-addr <-manager-address:2377-> --advertise-addr <-manager-address->
        sudo hostnamectl set-hostname ConfigSV
        sudo systemctl restart docker

### Join 2 nodes to the Swarm from the different datacenters in same AZ

You will have to ssh each datacenter, join and set the node hostname using:

        docker swarm join \
                --token <provided-token-by-the-manager> \
                <manager-address:2377>
        sudo hostnamectl set-hostname shard1
        sudo systemctl restart docker

        docker swarm join \
                --token <provided-token-by-the-manager> \
                <manager-address:2377>
        sudo hostnamectl set-hostname shard2
        sudo systemctl restart docker
### Update them from manager node to add the datacenter label {SAN/LAS/POW}

		docker node update --label-add datacenter=SAN ConfigSV
		docker node update --label-add datacenter=LAS shard1
		docker node update --label-add datacenter=POW shard2
### Create a network from manager node

        docker network create swarm_mongodb_minio_network --driver overlay

### ssh the manager and deploy the stack to docker swarm

		docker stack deploy -c docker-compose.yml MDBSCBM


