#
# This file is managed by Ansible.
#
# template: /etc/ansible/roles/ood/templates/jupyter/before.sh.erb.j2
#

# Export the module function if it exists
[[ $(type -t module) == "function" ]] && export -f module

# Find available port to run server on
port=$(find_port ${host})

# Generate SHA1 encrypted password (requires OpenSSL installed)
SALT="$(create_passwd 16)"
password="$(create_passwd 16)"
PASSWORD_SHA1="$(echo -n "${password}${SALT}" | openssl dgst -sha1 | awk '{print $NF}')"

# Notebook root directory
export NOTEBOOK_ROOT="${NOTEBOOK_ROOT:-${HOME}}"

# Set default runtime dir
export JUPYTER_RUNTIME_DIR="${HOME}/.jupyter/runtime"

# The `$CONFIG_FILE` environment variable is exported as it is used in the main
# `script.sh.erb` file when launching the Jupyter server.
export CONFIG_FILE="${PWD}/config.py"

# Generate Jupyter configuration file with secure file permissions
(
umask 077
cat > "${CONFIG_FILE}" << EOL
c.JupyterApp.config_file_name = 'ondemand_config'
c.KernelSpecManager.ensure_native_kernel = False
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.port = ${port}
c.NotebookApp.port_retries = 0
c.NotebookApp.password = u'sha1:${SALT}:${PASSWORD_SHA1}'
c.NotebookApp.base_url = '/node/${host}/${port}/'
c.NotebookApp.open_browser = False
c.NotebookApp.allow_origin = '*'
c.NotebookApp.notebook_dir = '/'
c.NotebookApp.disable_check_xsrf = True
c.NotebookApp.default_url = '/tree/scratch/kykwan_root/kykwan'
EOL
)
