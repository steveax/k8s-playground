plan k8s::install_helm(
  TargetSpec $targets = ['controller'],
) {
  run_command('curl https://baltocdn.com/helm/signing.asc | apt-key add -', $targets)
  run_command('apt-get install apt-transport-https --yes', $targets)
  run_command('echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list', $targets)
  run_command('apt-get update', $targets)
  run_task('package', $targets, 'action' => install, 'name' => 'helm')
}
