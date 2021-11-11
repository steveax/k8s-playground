plan k8s::add_node(
  TargetSpec $controller = 'controller',
  TargetSpec $targets,
  String $k8s_version = '1.22.0',
  Boolean $install_prereqs = true,
) {
  # Assert there is only one controller
  $controller.get_target

  if $install_prereqs {
    run_plan('k8s::install_prerequisites', $targets, k8s_version => $k8s_version)
  }

  $token_result = run_command("kubeadm token create --print-join-command", $controller).first

  run_command($token_result['stdout'].chomp, $targets)
}
