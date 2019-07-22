from datetime import timedelta, datetime

from airflow import DAG
from airflow.contrib.operators.kubernetes_pod_operator import KubernetesPodOperator


default_args = {
    'depends_on_past': False,
    'execution_timeout': timedelta(minutes=10),
    'email': [],
    'email_on_failure': False,
    'email_on_retry': False,
    'owner': 'sample',
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
    'start_date': datetime(2018, 1, 1),
}

dag = DAG(
    dag_id='sample_kubernetes_dag',
    default_args=default_args,
    schedule_interval='*/5 * * * *',
    catchup=False,
)

run_first = KubernetesPodOperator(
    task_id='run_me_first',
    name='run-me-first',
    namespace='default',
    in_cluster=True,
    is_delete_operator_pod=False,
    startup_timeout_seconds=120,
    image='bash',
    image_pull_policy='Always',
    cmds=['echo'],
    arguments=['Starting this DAG for execution date: {{ ds }}'],
    dag=dag,
)

run_last = KubernetesPodOperator(
    task_id='run_me_last',
    name='run-me-last',
    namespace='default',
    in_cluster=True,
    is_delete_operator_pod=False,
    image='bash',
    cmds=['echo'],
    arguments=['Ending the DAG'],
    dag=dag,
)

for i in range(5):
    t1 = KubernetesPodOperator(
        task_id='run_this_t1_{i}'.format(i=i),
        name='run-this-t1-{i}'.format(i=i),
        namespace='default',
        in_cluster=True,
        is_delete_operator_pod=False,
        image='bash',
        cmds=['echo'],
        arguments=['The task instance key is: ', '{{ task_instance_key_str }}'],
        dag=dag,
    )

    t2 = KubernetesPodOperator(
        task_id='run_this_t2_{i}'.format(i=i),
        name='run-this-t2-{i}'.format(i=i),
        namespace='default',
        in_cluster=True,
        is_delete_operator_pod=False,
        image='bash',
        cmds=['echo'],
        arguments=['The task instance key is: ', '{{ task_instance_key_str }}'],
        dag=dag,
    )

    t3 = KubernetesPodOperator(
        task_id='run_this_t3_{i}'.format(i=i),
        name='run-this-t3-{i}'.format(i=i),
        namespace='default',
        in_cluster=True,
        is_delete_operator_pod=False,
        image='bash',
        cmds=['echo'],
        arguments=['The task instance key is: ', '{{ task_instance_key_str }}'],
        dag=dag,
    )

    t4 = KubernetesPodOperator(
        task_id='run_this_t4_{i}'.format(i=i),
        name='run-this-t4-{i}'.format(i=i),
        namespace='default',
        in_cluster=True,
        is_delete_operator_pod=False,
        image='bash',
        cmds=['echo'],
        arguments=['The task instance key is: ', '{{ task_instance_key_str }}'],
        dag=dag,
    )

    run_first.set_downstream([t1, t3])
    t1.set_downstream(t2)
    t3.set_downstream(t4)
    run_last.set_upstream([t2, t4])
