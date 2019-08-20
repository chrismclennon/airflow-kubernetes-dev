# airflow-kubernetes-dev
Development environment for Airflow on Kubernetes.

Simply clone this repo, and run `kubectl apply -f airflow.yaml`. You can find the IP to connect to your service using `kubectl -n airflow get svc`.

Check branch names to see different versions of this environment that are available.
