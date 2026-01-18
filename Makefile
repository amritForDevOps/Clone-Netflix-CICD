.PHONY: tf-init tf-apply build-netflix-clone apply-k8s install-monitoring

tf-init:
	cd terraform && terraform init

tf-apply:
	cd terraform && terraform apply 

build-netflix-clone:
	@echo "Requires AWS_ACCOUNT_ID and AWS_REGION env vars"
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
	docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/netflix-clone:latest ../.
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/netflix-clone:latest

apply-k8s:
	kubectl apply -f k8s/base/

install-monitoring:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f k8s/prometheus-grafana/values.yaml
	kubectl apply -f k8s/prometheus-grafana/servicemonitor-backend.yaml -n monitoring


