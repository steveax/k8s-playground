plan k8s::add_pe(
  String $chart_path,
  TargetSpec $targets = ['controller'],
) {
  upload_file($chart_path, '/tmp', $targets)
  #run_command('export KUBECONFIG=/etc/kubernetes/admin.conf')
  run_command("KUBECONFIG=/etc/kubernetes/admin.conf helm install pe-orchestration-services /tmp/puppet-enterprise-1.0.0.tgz --wait", $targets)
}
