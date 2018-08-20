source ./lib/extended-oc.sh

ARGS_FILE=00.01-refresh-all-openshift-projects.config

# ====================================================================================
# Order dependent
# No spaces
# Set these in the above config file
APPLICATION_NAME=the-application-name
TOOLS_PROJECT=the-target-tools-project
TOOLS_TEMPLATE=the-template-file-to-be-applied-at-the-tools-project
TOOLS_TEMPLATE_PARAMETERS_FILE=the-inputs-passed-in-to-the-tools-template-file
DEV_PROJECT=the-development-environment-project
DEV_TEMPLATE=the-template-file-to-be-applied-at-the-development-environment-project
DEV_TEMPLATE_PARAMETERS_FILE=the-inputs-passed-in-to-the-development-environment-template-file
DEV_NGINX_NAME=the-existing-nginx-project-deployment-in-the-dev-project
DEV_NGINX_PROXY=http://the-application-name:4000
DEV_NGINX_USERNAME=the-one-username-everyone-using-this-eguide-will-share
DEV_NGINX_PASSWORD=the-one-password-everyone-using-this-eguide-will-share
TEST_PROJECT=the-test-environment-project
TEST_TEMPLATE=the-template-file-to-be-applied-at-the-test-environment-project
TEST_TEMPLATE_PARAMETERS_FILE=the-inputs-passed-in-to-the-test-environment-template-file
TEST_NGINX_NAME=existing-nginx-project-deployment-in-the-test-project
TEST_NGINX_PROXY=http://the-application-name:4000
TEST_NGINX_USERNAME=the-one-username-everyone-using-this-eguide-will-share
TEST_NGINX_PASSWORD=the-one-password-everyone-using-this-eguide-will-share
PROD_PROJECT=the-production-environment-project
PROD_TEMPLATE=the-template-file-to-be-applied-at-the-production-environment-project
PROD_TEMPLATE_PARAMETERS_FILE=the-inputs-passed-in-to-the-production-environment-template-file
PROD_NGINX_NAME=existing-nginx-project-deployment-in-the-prod-project
PROD_NGINX_PROXY=http://the-application-name:4000
PROD_NGINX_USERNAME=the-one-username-everyone-using-this-eguide-will-share
PROD_NGINX_PASSWORD=the-one-password-everyone-using-this-eguide-will-share
# ====================================================================================

refreshAll() {
    clear
    checkFileExists "config", ${ARGS_FILE}
    checkJqPresent
    checkOpenshiftSession

    local _application_name=${1}
    local _tools_project=${2}
    local _tools_template=${3}
    local _tools_template_parameters_file=${4}
    local _dev_project=${5}
    local _dev_template=${6}
    local _dev_template_parameters_file=${7}
    local _dev_nginx_name=${8}
    local _dev_nginx_proxy=${9}
    local _dev_nginx_username=${10}
    local _dev_nginx_password=${11}
    local _test_project=${12}
    local _test_template=${13}
    local _test_template_parameters_file=${14}
    local _test_nginx_name=${15}
    local _test_nginx_proxy=${16}
    local _test_nginx_username=${17}
    local _test_nginx_password=${18}
    local _prod_project=${19}
    local _prod_template=${20}
    local _prod_template_parameters_file=${21}
    local _prod_nginx_name=${22}
    local _prod_nginx_proxy=${23}
    local _prod_nginx_username=${24}
    local _prod_nginx_password=${25}

    if [ -z "${_application_name}" ] \
    || [ -z "${_tools_project}" ] || [ -z "${_tools_template}" ] || [ -z "${_tools_template_parameters_file}" ] \
    || [ -z "${_dev_project}" ] || [ -z "${_dev_template}" ] || [ -z "${_dev_template_parameters_file}" ] \
    || [ -z "${_dev_nginx_name}" ] || [ -z "${_dev_nginx_proxy}" ] \
    || [ -z "${_dev_nginx_username}" ] || [ -z "${_dev_nginx_password}" ] \
    || [ -z "${_test_project}" ] || [ -z "${_test_template}" ] || [ -z "${_test_template_parameters_file}" ] \
    || [ -z "${_test_nginx_name}" ] || [ -z "${_test_nginx_proxy}" ] \
    || [ -z "${_test_nginx_username}" ] || [ -z "${_test_nginx_password}" ] \
    || [ -z "${_prod_project}" ] || [ -z "${_prod_template}" ] || [ -z "${_prod_template_parameters_file}" ] \
    || [ -z "${_prod_nginx_name}" ] || [ -z "${_prod_nginx_proxy}" ] \
    || [ -z "${_prod_nginx_username}" ] || [ -z "${_prod_nginx_password}" ]; then
        echo -e \\n"refreshAll: Missing parameter! Parameters have to be present, even if empty."\\n
        exit 1
    fi

    APPLICATION_NAME=${_application_name/APPLICATION_NAME=/}

    # deploy is an array so we can loop through the similar projects and reuse our code
    declare -a deploy
    local num_rows=4
    local num_columns=7
    declare -a toolsEnv
    declare -a devEnv
    declare -a testEnv
    declare -a prodEnv

    local tools=0
    local dev=1
    local test=2
    local prod=3

    local project=0
    local template=1
    local params=2
    local nginx_name=3
    local nginx_proxy=4
    local nginx_username=5
    local nginx_password=6

    toolsEnv[$project]=${_tools_project/TOOLS_PROJECT=/}
    toolsEnv[$template]=${_tools_template/TOOLS_TEMPLATE=/}
    toolsEnv[$params]=${_tools_template_parameters_file/TOOLS_TEMPLATE_PARAMETERS_FILE=/}
    toolsEnv[$nginx_name]=""
    toolsEnv[$nginx_proxy]=""
    toolsEnv[$nginx_username]=""
    toolsEnv[$nginx_password]=""
    deploy[$tools]=${toolsEnv[@]}
    devEnv[$project]=${_dev_project/DEV_PROJECT=/}
    devEnv[$template]=${_dev_template/DEV_TEMPLATE=/}
    devEnv[$params]=${_dev_template_parameters_file/DEV_TEMPLATE_PARAMETERS_FILE=/}
    devEnv[$nginx_name]=${_dev_nginx_name/DEV_NGINX_NAME=/}
    devEnv[$nginx_proxy]=${_dev_nginx_proxy/DEV_NGINX_PROXY=/}
    devEnv[$nginx_username]=${_dev_nginx_username/DEV_NGINX_USERNAME=/}
    devEnv[$nginx_password]=${_dev_nginx_password/DEV_NGINX_PASSWORD=/}
    deploy[$dev]=${devEnv[@]}
    testEnv[$project]=${_test_project/TEST_PROJECT=/}
    testEnv[$template]=${_test_template/TEST_TEMPLATE=/}
    testEnv[$params]=${_test_template_parameters_file/TEST_TEMPLATE_PARAMETERS_FILE=/}
    testEnv[$nginx_name]=${_test_nginx_name/TEST_NGINX_NAME=/}
    testEnv[$nginx_proxy]=${_test_nginx_proxy/TEST_NGINX_PROXY=/}
    testEnv[$nginx_username]=${_test_nginx_username/TEST_NGINX_USERNAME=/}
    testEnv[$nginx_password]=${_test_nginx_password/TEST_NGINX_PASSWORD=/}
    deploy[$test]=${testEnv[@]}
    prodEnv[$project]=${_prod_project/PROD_PROJECT=/}
    prodEnv[$template]=${_prod_template/PROD_TEMPLATE=/}
    prodEnv[$params]=${_prod_template_parameters_file/PROD_TEMPLATE_PARAMETERS_FILE=/}
    prodEnv[$nginx_name]=${_prod_nginx_name/PROD_NGINX_NAME=/}
    prodEnv[$nginx_proxy]=${_prod_nginx_proxy/PROD_NGINX_PROXY=/}
    prodEnv[$nginx_username]=${_prod_nginx_username/PROD_NGINX_USERNAME=/}
    prodEnv[$nginx_password]=${_prod_nginx_password/PROD_NGINX_PASSWORD=/}
    deploy[$prod]=${prodEnv[@]}

    local project_label=""
    local artifact_label=""

    for ((i=0;i<num_rows;i++)) do
        if ((0 < i)); then
            echo -e \\n
        fi
        unset current_project
        declare -a current_project=( ${deploy[$i]} )
        if [ "${tools}" -eq "${i}" ]; then 
            project_label="tools"
        elif  [ "${dev}" -eq "${i}" ]; then 
            project_label="dev"
        elif [ "${test}" -eq "${i}" ]; then 
            project_label="test"
        elif [ "${prod}" -eq "${i}" ]; then 
            project_label="prod"
        fi 
        for ((j=0;j<num_columns;j++)) do
            if [ "${project}" -eq "${j}" ]; then
                artifact_label="project"
            elif [ "${template}" -eq "${j}" ]; then
                artifact_label="template"
            elif [ "${params}" -eq "${j}" ]; then
                artifact_label="params"
            elif [ "${nginx_name}" -eq "${j}" ]; then
                artifact_label="nginx_name"
            elif [ "${nginx_proxy}" -eq "${j}" ]; then
                artifact_label="nginx_proxy"
            #elif [ "${nginx_authentication_type}" -eq "${j}" ]; then
            #    artifact_label="nginx_authentication_type"
            elif [ "${nginx_username}" -eq "${j}" ]; then
                artifact_label="nginx_username"
            elif [ "${nginx_password}" -eq "${j}" ]; then
                artifact_label="nginx_password"
            fi
            #echo ${current_project[$j]}
            if [ -z "${current_project[$j]}" ]; then
                unset current_project
                echo -e \\n"refreshAll: Empty ${project_label} ${artifact_label} parameter.  Skipping refresh for this project."\\n
                break
            fi
            #tools doesn't have an nginx to check, so skip anything after params
            if [ "${tools}" -eq "${i}" ] && [ "${params}" -eq "${j}" ]; then
                break
            fi
        done
        if [ -z "${current_project}" ]; then
            continue
        fi
        #echo "${current_project[$project]}"
        checkProjectExists ${current_project[$project]}
        checkFileExists "template", ${current_project[$template]}
        checkFileExists "parameters", ${current_project[$params]}

        #echo "project '${current_project[$project]}'"
        #echo "template '${current_project[$template]}'"
        #echo "parameters '${current_project[$params]}'"
        oc project ${current_project[$i,$project]}
        cleanProject ${APPLICATION_NAME} ${current_project[$i,$project]}

        #if [ "${tools}" -eq "${i}" ]; then
            #oc create secret generic regulatory-cont-eguide-ssh --from-file=ssh-privatekey="./.ssh/regulatory-continuum-eguide-ssh" --from-file=ssh-publickey="./.ssh/regulatory-continuum-eguide-ssh.pub" --from-literal=passphrase=""
        #fi
        
        oc process -f ${current_project[$i,$template]} --param-file=${current_project[$i,$params]} -n ${current_project[$i,$project]} | oc create -f -

        if ! [ "${tools}" -eq "${i}" ]; then
#            oc create configmap ${APPLICATION_NAME} -n ${current_project[$i,$project]}
#            _tag_name=latest
            local _cli_output
            if [ "${prod}" -eq "${i}" ]; then
                _cli_output=$(oc delete route ${APPLICATION_NAME} -n ${current_project[$i,$project]} 2>&1)
                outputRelevantOnly "${_cli_output}"
            fi
#            _cli_output=$(oc rollout ${_tag_name} ${_application_name} -n ${current_project[$i,$project]} 2>&1)
#            outputRelevantOnly "${_cli_output}"
        fi

        if [ -z "${current_project[$nginx_name]}" ] || [ -z "${current_project[$nginx_proxy]}" ] || [ -z "${current_project[$nginx_authentication_type]}" ] \
        || [ -z "${current_project[$nginx_username]}" ] || [ -z "${current_project[$nginx_password]}" ]; then
            continue
        fi
        checkNginxExists ${current_project[$nginx_name]}

        #oc set env dc/${current_project[$nginx_name]} --list -n ${current_project[$i,$project]}
        #TODO: automate this to latest available number and check if more than 9
        local _s2i_cred_num=2  #see usr/libexec/s2i/run for implementation
        oc set env dc/${current_project[$nginx_name]} REGULATORY_CONTINUUM_EGUIDE_NGINX_PROXY=${current_project[$nginx_proxy]} \
        HTTP_BASIC${_s2i_cred_num}="auth_basic \"Restricted Content\"; auth_basic_user_file /tmp/.htpasswd${_s2i_cred_num};" \
        USERNAME${_s2i_cred_num}=${current_project[$nginx_username]} \
        PASSWORD${_s2i_cred_num}=${current_project[$nginx_password]} \
         -n ${current_project[$i,$project]}
        #oc set env dc/${current_project[$nginx_name]} --list -n ${current_project[$i,$project]}
        
        echo "Waiting 30 seconds for pods to come up..."
        sleep 30s
        checkDeploymentIsUp ${APPLICATION_NAME} ${current_project[$i,$project]}
        # we can't redeploy the nginx application until the pods for our eguide are up otherwise
        # nginx gets stuck in a bad state when trying to route there
        local _cli_output 
        _cli_output=$(oc rollout latest dc/${current_project[$nginx_name]} -n ${current_project[$i,$project]} 2>&1) 
        outputRelevantOnly "${_cli_output}"
    done
    echo -e \\n"refreshAll: Complete run."\\n
}

refreshAll $(<${ARGS_FILE})
