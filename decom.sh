echo "[Credentials]" >> /etc/boto.cfg
echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> /etc/boto.cfg
echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> /etc/boto.cfg
CLUSTER_ID=`aws ec2 describe-instances --filter Name=tag:coco-environment-tag,Values=$ENVIRONMENT_TAG | jq '.Reservations[0]' | grep -Po -m 1 ".*ft.{3}\K.{8}(?=-caw1a-eu-p)"`
echo "ClusterID: $CLUSTER_ID"

## activate virtual environment
. .venv/bin/activate

INSTANCE_IDS=$(aws ec2 describe-instances --filter Name=tag:coco-environment-tag,Values=$ENVIRONMENT_TAG | jq '{"instanceIds": [.Reservations[].Instances[].InstanceId]}')
INSTANCE_IDS=`echo $INSTANCE_IDS`
echo "Instances: $INSTANCE_IDS"

ansible-playbook -i ~/.ansible_hosts /ansible/decom.yml \
  --extra-vars "$INSTANCE_IDS" \
  --extra-vars " \
  clusterid=$CLUSTERID \
  aws_access_key_id=$AWS_ACCESS_KEY_ID \ 
  aws_secret_access_key=$AWS_SECRET_ACCESS_KEY \
  region=$AWS_DEFAULT_REGION \
  environment_tag=${ENVIRONMENT_TAG}"

