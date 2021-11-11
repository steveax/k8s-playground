plan k8s::init_cluster(
  TargetSpec $controller = 'controller',
  TargetSpec $workers = 'worker-nodes',
  String $k8s_version = '1.22.0',
) {
  # Assert there is only one controller
  $controller.get_target

  run_plan('k8s::install_prerequisites', [$controller, $workers], k8s_version => $k8s_version)

  $config_exists = run_command('[ -f /etc/kubernetes/admin.conf ]', $controller, _catch_errors => true)
  if !$config_exists.ok {
    run_command("kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version=${k8s_version}", $controller)
  }
  $download_result = download_file('/etc/kubernetes/admin.conf', 'kubeconfig', $controller).first

  out::message("export KUBECONFIG=${download_result['path']}")

  run_command("KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml", $controller)

  run_plan('k8s::add_node', $workers, controller => $controller, k8s_version => $k8s_version, install_prereqs => false)
}
