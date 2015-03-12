#!/bin/sh

ACTION=$1

if [ $# == 2 ]; then
  R10K_ENVIRONMENT="$2"
else
  echo "No environment set. Defaulting to 'production'."
  R10K_ENVIRONMENT="production"
fi

BASE_DIR="${HOME}/pe_r10k_files"
R10K_CACHE_DIR="${BASE_DIR}/cache/r10k"
R10K_HIERA_DIR="${BASE_DIR}/hiera"
R10K_PUPPETFILE_DIR="${BASE_DIR}/environments"
R10K_YAML_FILE="./r10k.yaml"
R10K_REMOTE_PUPPETFILE="https://github.webapps.rr.com/fylgia/puppetfile.git"
REMOTE_HIERA="git@github.webapps.rr.com:fylgia/hieradata.git"

PE_MODULE_DIR="${HOME}/pe_modules"
PE_HIERA_DIR="${HOME}/pe_hiera"

############
#
# Check and Create directories
checkAndCreateDir () {
  echo "checking to ensure r10k is installed"
  GEM_OUTPUT=`gem list | grep r10k`
  if [ "${GEM_OUTPUT}" == "" ]; then
    gem install r10k || { echo 'Installation of r10k failed' ; exit 1; }
  fi

  echo "Verifying directories for use with r10k"
  if [ ! -d "${R10K_PUPPETFILE_DIR}/${R10K_ENVIRONMENT}" ]; then
    echo "Creating ${R10K_PUPPETFILE_DIR}/${R10K_ENVIRONMENT}"
    mkdir -p ${R10K_PUPPETFILE_DIR}/${R10K_ENVIRONMENT}
  fi

  # if [ ! -d "${R10K_HIERA_DIR}/${R10K_ENVIRONMENT}" ]; then
  #   echo "Creating ${R10K_HIERA_DIR}/${R10K_ENVIRONMENT}"
  #   mkdir -p ${R10K_HIERA_DIR}/${R10K_ENVIRONMENT}
  # fi

  mkdir -p ${R10K_CACHE_DIR}
  chmod 777 ${R10K_CACHE_DIR}
}
############
#
# Create r10k.yaml file
createR10kFile () {

  echo "Creating ${R10K_YAML_FILE} file"
  cat /dev/null > ${R10K_YAML_FILE}

#To avoid syntax problem this sections need to be aligned to first column
cat << EOT >> ${R10K_YAML_FILE}
:cachedir: "${R10K_CACHE_DIR}"
:sources:
  :local:
    remote: "${R10K_REMOTE_PUPPETFILE}"
    basedir: "${R10K_PUPPETFILE_DIR}"
EOT

}
############

case ${ACTION} in
  setup)

    if [ -d "${PE_MODULE_DIR}" ]; then
      echo "${PE_MODULE_DIR} already exists"
      exit 1
    fi

    checkAndCreateDir
    createR10kFile

    r10k deploy -v debug environment ${R10K_ENVIRONMENT} -p

    WORKING_MODULES_DIR="${R10K_PUPPETFILE_DIR}/${R10K_ENVIRONMENT}/modules"
    WORKING_MODULE_LIST=`ls -1 ${WORKING_MODULES_DIR}`

    for MODULE in `echo ${WORKING_MODULE_LIST}`; do
      GIT_CONFIG_FILE=${WORKING_MODULES_DIR}/${MODULE}/.git/config
      if [ -e "${GIT_CONFIG_FILE}" ]; then
        echo "Git config exists for ${MODULE}"
        cd ${WORKING_MODULES_DIR}/${MODULE}
        echo "\tRemoving remote entry for cache on module ${MODULE}"
        #git status
        git remote rm cache
        git checkout master
      fi
    done

    echo "\tObtaining Hiera repository"
    cd ${HOME}
    git clone ${REMOTE_HIERA} --branch ${R10K_ENVIRONMENT} pe_hiera

    mv ${WORKING_MODULES_DIR} ${PE_MODULE_DIR}
    MESSAGE="\n\nEnvironment ${R10K_ENVIRONMENT} as been set up at ~/pe_modules and ~/pe_hiera. \n Do not forget to create a new branch for your module"

    ;;
  cleanup)
    DELETE_LIST="${PE_HIERA_DIR} ${PE_MODULE_DIR} ${R10K_CACHE_DIR} ${R10K_PUPPETFILE_DIR} ${R10K_YAML_FILE}"
    echo "Removing: ${DELETE_LIST}"
    rm -rf ${DELETE_LIST}
    MESSAGE="Removal of files compelete"
    ;;
  *)
    MESSAGE="No action set.  Valid action are: setup, cleanup"
    ;;
esac

echo "${MESSAGE}"
