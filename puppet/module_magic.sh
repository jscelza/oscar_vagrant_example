#!/bin/sh

ACTION=$1
R10K_ENVIRONMENT="production"

BASE_DIR="${HOME}/pe_r10k_files"
R10K_CACHE_DIR="${BASE_DIR}/cache/r10k"
R10K_HIERA_DIR="${BASE_DIR}/hiera"
R10K_PUPPETFILE_DIR="${BASE_DIR}/environments"
R10K_YAML_FILE="${BASE_DIR}/r10k.yaml"

PE_MODULE_DIR="${HOME}/pe_modules"
PE_HIERA_DIR="${HOME}/pe_hiera"

############
#
# Check and Create directories
checkAndCreateDir () {
  echo "Verifying directories for use with r10k"
  if [ ! -d "${R10K_PUPPETFILE_DIR}" ]; then
    echo "Creating ${R10K_PUPPETFILE_DIR}"
    mkdir -p ${R10K_PUPPETFILE_DIR}
  fi
  if [ ! -d "${R10K_HIERA_DIR}" ]; then
    echo "Creating ${R10K_HIERA_DIR}"
    mkdir -p ${R10K_HIERA_DIR}
  fi
}
############
#
# Create r10k.yaml file
createR10kFile () {

  echo "Creating r10k yaml file"
  cat /dev/null > ${R10K_YAML_FILE}

  cat << EOT >> ${R10K_YAML_FILE}
  :cachedir: "${R10K_CACHE_DIR}"
  :sources:
    :operations:
      remote: 'git@github.webapps.rr.com:fylgia/puppetfile.git'
      basedir: "${R10K_PUPPETFILE_DIR}"
    :hiera:
      remote: 'git@github.webapps.rr.com:fylgia/hieradata.git'
      basedir: "${R10K_HIERA_DIR}"
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

    mkdir -p ${R10K_CACHE_DIR}
    chmod 777 ${R10K_CACHE_DIR}
    r10k deploy -v -c ${R10K_YAML_FILE} environment ${R10K_ENVIRONMENT} -p

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

    echo "\tRemoving remote entry for cache on hiera"
    cd ${R10K_HIERA_DIR}/${R10K_ENVIRONMENT}
    git remote rm cache
    git checkout master
    mv ${WORKING_MODULES_DIR} ${PE_MODULE_DIR}
    mv ${R10K_HIERA_DIR}/${R10K_ENVIRONMENT} ${PE_HIERA_DIR}
    MESSAGE="Environment ${R10K_ENVIRONMENT} as been set up at ~/pe_modules and ~/pe_hiera. \n Do not forget to change your branch"

    ;;
  cleanup)
    DELETE_LIST="${PE_HIERA_DIR} ${PE_MODULE_DIR} ${R10K_CACHE_DIR} ${R10K_HIERA_DIR} ${R10K_PUPPETFILE_DIR} ${R10K_YAML_FILE}"
    echo "Removing: ${DELETE_LIST}"
    rm -rf ${DELETE_LIST}
    MESSAGE="Removal of files compelete"
    ;;
  *)
    MESSAGE="No action set.  Valid action are: setup, cleanup"
    ;;
esac

echo "${MESSAGE}"
