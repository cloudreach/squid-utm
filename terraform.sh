#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#/
#/ Usage:
#/    ./terraform.sh [action]
#/ Description:
#/    Terraform Wrapper Script
#/ Examples:
#/    ./terraform.sh plan
#/    ./terraform.sh apply
#/ Actions:
#/    init     - Init configuration
#/    validate - Validate terraform file
#/    plan     - Test terraform configuration
#/    apply    - Apply terraform configuration
#/    destroy  - Destroy all resources created in terraform
#/ Options:
#/    --help: Display this help message
#/
#/

usage() { grep '^#/' "${0}" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

readonly LOG_FILE="/tmp/$(basename "${0}").log"
info()    { echo "[INFO]    $*" | tee -a "${LOG_FILE}" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "${LOG_FILE}" >&2 ; }
error()   { echo "[ERROR]   $*" | tee -a "${LOG_FILE}" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "${LOG_FILE}" >&2 ; exit 1 ; }



terraform_fmt() {
    info "Running terraform fmt"
    terraform fmt || fatal "Could not fmt terraform"
}

terraform_lint() {
    info "Running terraform lint"
    terraform fmt -diff=true -check  || fatal "Could not lint terraform"
}

terraform_validate() {
    info "Running terraform validate"
    for i in $(find . -type f -name "*.tf" -exec dirname {} \; | grep -v "/test"); do 
        terraform validate "$i" || fatal "Could not validate terraform"
        if [ $? -ne 0 ]; then 
                error "Failed Terraform .tf file validation"
        fi;
    done
}



terraform_init() {
    info "Running terraform init"
    terraform init -input=false || fatal "Could not initialize terraform"
}

terraform_plan() {
    info "Running terraform plan"
    terraform plan -out=plan.out || error "Terraform plan failed"
}

terraform_apply() {
    terraform_plan
    info "Running terraform apply"
    terraform apply  \
        -lock=true \
        -input=false \
        -refresh=true \
        -auto-approve=true \
        ./plan.out || error "Terraform apply failed"
}

terraform_destroy() {
    info "Running terraform destroy"
    terraform destroy \
        -lock=true \
        -input=false \
        -refresh=true \
        -force || error "Terraform destroy failed"
    rm -rf tfplan 
    rm -rf terraform.tfstate.backup  
    rm -rf .terraform
}




setup() {
    terraform_fmt
    if [[ ! -d ".terraform" ]] ; then
        terraform_init
    fi
}



cleanup() {
    info "Cleaning up temporary files."
    rm -rf plan.out
}

if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
    trap cleanup EXIT
    setup
    if [[ ${#} -gt 0 ]] ; then
        case "${1}" in
            "init")
                terraform_init
                ;;
            "validate")
                terraform_validate
                ;;
            "plan")
                terraform_plan
                ;;
            "apply")
                terraform_apply
                ;;
            "destroy")
                terraform_destroy
                ;;
            "help")
                usage
                ;;
            *)
                fatal "Unknown command: ${1} $(usage)"
                ;;
        esac
    else
        fatal "No command supplied $(usage)"
    fi
fi
