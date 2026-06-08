#!/usr/bin/env bash

OUT="install.md"

run_section() {
  local title="$1"
  shift

  {
    echo
    echo "## $title"
    echo
    echo '```text'
  } >> "$OUT"

  if "$@" >> "$OUT" 2>&1; then
    true
  else
    echo "Command failed or tool not installed: $*" >> "$OUT"
  fi

  {
    echo '```'
  } >> "$OUT"
}

run_if_exists() {
  local title="$1"
  local cmd="$2"
  shift 2

  if command -v "$cmd" >/dev/null 2>&1; then
    run_section "$title" "$cmd" "$@"
  else
    {
      echo
      echo "## $title"
      echo
      echo '```text'
      echo "$cmd is not installed or not in PATH."
      echo '```'
    } >> "$OUT"
  fi
}

{
  echo "# Installed Software Inventory"
  echo
  echo "- Generated: $(date)"
  echo "- Hostname: $(hostname)"
  echo "- User: $(whoami)"
  echo "- Kernel: $(uname -a)"
  echo "- Shell: ${SHELL:-unknown}"
  echo "- Working directory: $(pwd)"
} > "$OUT"

run_section "Operating System Release" bash -c '
if [ -f /etc/os-release ]; then
  cat /etc/os-release
else
  sw_vers 2>/dev/null || uname -a
fi
'

run_section "CPU and Memory Summary" bash -c '
echo "CPU:"
lscpu 2>/dev/null || sysctl -n machdep.cpu.brand_string 2>/dev/null || true
echo
echo "Memory:"
free -h 2>/dev/null || vm_stat 2>/dev/null || true
'

run_section "Disk Usage" df -h

run_section "PATH" bash -c 'echo "$PATH" | tr ":" "\n"'

run_if_exists "APT Packages" apt list --installed
run_if_exists "DPKG Packages" dpkg-query -W
run_if_exists "DNF Packages" dnf list installed
run_if_exists "YUM Packages" yum list installed
run_if_exists "RPM Packages" rpm -qa
run_if_exists "Pacman Packages" pacman -Q
run_if_exists "Homebrew Packages" brew list --versions
run_if_exists "Snap Packages" snap list
run_if_exists "Flatpak Packages" flatpak list

run_if_exists "Python Version" python --version
run_if_exists "Python3 Version" python3 --version
run_if_exists "Pip Packages" pip list
run_if_exists "Pip3 Packages" pip3 list

run_if_exists "Node Version" node --version
run_if_exists "NPM Version" npm --version
run_if_exists "Global NPM Packages" npm list -g --depth=0

run_if_exists "Go Version" go version
run_if_exists "Rust Version" rustc --version
run_if_exists "Cargo Packages" cargo install --list
run_if_exists "Java Version" java -version
run_if_exists "Maven Version" mvn --version
run_if_exists "Gradle Version" gradle --version

run_if_exists "Git Version" git --version
run_if_exists "Docker Version" docker --version
run_if_exists "Docker Compose Version" docker compose version
run_if_exists "Docker Images" docker images
run_if_exists "Docker Containers" docker ps -a

run_if_exists "Terraform Version" terraform version
run_if_exists "AWS CLI Version" aws --version
run_if_exists "Azure CLI Version" az version
run_if_exists "Google Cloud CLI Version" gcloud version
run_if_exists "Kubectl Version" kubectl version --client
run_if_exists "Helm Version" helm version
run_if_exists "Ansible Version" ansible --version

run_if_exists "VS Code Extensions" code --list-extensions --show-versions

run_section "Common DevOps/Security Tool Locations" bash -c '
for tool in git docker terraform aws az gcloud kubectl helm ansible python python3 pip pip3 node npm go rustc cargo java mvn gradle code jq yq curl wget openssl ssh; do
  printf "%-15s " "$tool"
  command -v "$tool" || echo "not found"
done
'

echo
echo "Inventory saved to: $OUT"
