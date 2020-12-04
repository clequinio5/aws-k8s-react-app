eksctl create cluster \
--name aws-k8s-react-app \
--version 1.17 \
--region eu-west-3 \
--node-type t2.small \
--nodes 3 \
--nodes-min 1 \
--nodes-max 4 \
--managed