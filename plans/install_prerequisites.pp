plan k8s::install_prerequisites(
  TargetSpec $targets = ['controller', 'worker-nodes'],
  String $k8s_version = '1.22.0',
) {
  run_command('apt-get update -yy', $targets)
  run_task('package', $targets, 'action' => install, 'name' => 'apt-transport-https')
  run_command('curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -', $targets)
  write_file('deb https://apt.kubernetes.io/ kubernetes-xenial main', '/etc/apt/sources.list.d/kubernetes.list', $targets)
  $apt_update = background() || { run_command('apt-get update -yy', $targets) }

  # Configure kernel modules
  write_file("overlay\nbr_netfilter", '/etc/modules-load.d/containerd', $targets)
  run_command("modprobe overlay", $targets)
  run_command("modprobe br_netfilter", $targets)

  # Set sysctl settings
  upload_file('k8s/files/99-kubernetes-cri.conf', '/etc/sysctl.d', $targets)
  run_command('sysctl --system', $targets)

  # Install containerd
  $apt_update.wait
  run_task('package', $targets, 'action' => install, 'name' => 'containerd')

  # Generate default configuration and restart service to apply it
  run_command('mkdir -p /etc/containerd', $targets)
  run_command('containerd config default > /etc/containerd/config.toml', $targets)
  run_task('service', $targets, 'action' => restart, 'name' => 'containerd')

  # Disable swap
  run_command('swapoff -a', $targets)
  run_command("sed -i '/ swap / s/^\\(.*\\)$/#\\1/g' /etc/fstab", $targets)

  # Install k8s packages
  $package_version = "${k8s_version}-00"
  run_command("apt-get install -y kubelet=${package_version} kubeadm=${package_version} kubectl=${package_version}", $targets)
}
