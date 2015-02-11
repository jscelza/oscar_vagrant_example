#!/bin/sh

ACTION=`echo $1 | tr '[:upper:]' '[:lower:]'`

PE_RAKE_BASE="/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile RAILS_ENV=production"
VAGRANT_BASE_SSH="vagrant ssh master -c"

############
#

############

case ${ACTION} in
  addclass|ac)
    ROLE_NAME=$2
    if [ -z "${ROLE_NAME}" ]; then
      echo "Role Name is empty."
      echo "Example: $0 ${ACTION} role::mine"
      exit 1
    fi
    ${VAGRANT_BASE_SSH} "/usr/bin/sudo ${PE_RAKE_BASE} nodeclass:add name=${ROLE_NAME}"
    ;;

  class2node|c2n)
    ROLE_NAME=$2
    if [ -z "${ROLE_NAME}" ]; then
      echo "Role Name is empty."
      echo "Example: $0 ${ACTION} role::mine mynode"
      exit 1
    fi
    NODE_NAME=$3
    if [ -z "${NODE_NAME}" ]; then
      echo "Node Name is empty."
      echo "Example: $0 ${ACTION} ${ROLE_NAME} mynode"
      exit 1
    fi
    ${VAGRANT_BASE_SSH} "/usr/bin/sudo ${PE_RAKE_BASE} node:addclass name=${NODE_NAME} class=${ROLE_NAME}"
    ;;

  deletenode|delnode|dn)
    NODE_NAME=$2
    if [ -z "${NODE_NAME}" ]; then
      echo "Role Name is empty."
      echo "Example: $0 ${ACTION} mynode"
      exit 1
    fi
    ${VAGRANT_BASE_SSH} "/usr/bin/sudo ${PE_RAKE_BASE} node:del name=${NODE_NAME}"
    ${VAGRANT_BASE_SSH} "/usr/bin/sudo /usr/local/bin/puppet cert clean ${NODE_NAME}"
    ;;

  listclasses|lc)
    echo "The classes on master are: "
    ${VAGRANT_BASE_SSH} "/usr/bin/sudo ${PE_RAKE_BASE} nodeclass:list"
    ;;

  listclass4node|lc4n)
    NODE_NAME=$2
    if [ -z "${NODE_NAME}" ]; then
      echo "Role Name is empty."
      echo "Example: $0 ${ACTION} mynode"
      exit 1
    fi
    ${VAGRANT_BASE_SSH} "/usr/bin/sudo ${PE_RAKE_BASE} node:listclasses name=${NODE_NAME}"
    ;;

  *)
    MESSAGE="No action set.  Valid action are: addclass, class2node, deletenode, listclasses, listclass4node"
    ;;
esac

echo "${MESSAGE}"
