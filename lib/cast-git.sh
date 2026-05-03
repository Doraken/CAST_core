# ==============================================================================
#|# Script Name    : 00-init-mydev.sh
#|# Framework      : CAST - Common Application Scripting Toolkit
#|# Component      : Development Environment Initialization
#|# Version        : 0.1.0
#|# Author         : Arnaud Crampet
#|# mail           : arnaud@crampet.net
#|# Creation Date  : 2026-01-20
#|# Last Update    : 2026-04-30
#|# License        : GNU GPL 2.0
# ==============================================================================

function do_git_add ()
{
  #|# Description :
  #|# This function stages files in a Git repository by executing a `git add`
  #|# operation within the specified repository path. It is designed to be used
  #|# as part of the CAST automation workflow for source control management.
  #|#
  #|# The function ensures input validation, maintains execution traceability,
  #|# and logs Git operations for audit and troubleshooting purposes.
  #|#
  #|# Parameters :
  #|# ${1} : _repo_path
  #|#        Path to the target Git repository (Mandatory)
  #|#
  #|# ${2} : _file_name
  #|#        File or pattern to add to staging (Mandatory)
  #|#        Note: current implementation stages all files (git add .)
  #|#
  #|# Variables :
  #|# _repo_path : Target repository directory
  #|# _file_name : File or pattern intended for staging
  #|# actual     : Stores the current working directory before context switch
  #|# log_file   : CAST log file used to capture Git command output
  #|#
  #|# Behavior :
  #|# - Validates input parameters using do_empty_var_control
  #|# - Saves current working directory
  #|# - Checks repository availability (intended behavior)
  #|# - Switches to repository directory
  #|# - Executes `git add .` to stage all changes
  #|# - Logs command output to the configured log file
  #|# - Performs error control using do_error_control
  #|# - Restores original working directory
  #|#
  #|# Return / Output :
  #|# - No direct return value
  #|# - Emits CAST standardized messages
  #|# - Writes Git command output to log file
  #|#
  #|# Usage :
  #|# do_git_add "/path/to/repository" "file_or_pattern"
  #|#
  #|# Notes :
  #|# - Current implementation ignores _file_name and stages all files (git add .)
  #|# - Repository existence check appears incorrect and should validate _repo_path
  #|# - Variable 'repository' is used but not defined locally (potential defect)
  #|# - Message calls "EdSMessage"/"EdEMessage" are not properly invoked (missing set_message)
  #|#
  #|# Security / Compliance :
  #|# - Ensures traceability via logging
  #|# - Prevents execution with empty parameters
  #|# - Should validate repository path to avoid unintended directory changes
  #|# - Git operations should be executed with controlled permissions
	############ STACK_TRACE_BUILDER #####################
	Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
	######################################################
  local _repo_path="${1}"
  local _file_name="${2}"

  do_empty_var_control "${_repo_path}".    "_repo_path"    "2" "1" "0"
  do_empty_var_control "${_file_name}"     "_file_name"    "2" "1" "0"

  set_message "check" "1" "entenring git directory"
  actual=$(pwd)
  if [[ -d ${core_functions_loaded}  ]]
    then 
      cd ${repository} 
      "EdSMessage" "1" ""

      set_message "check" "1" "adding all files to commit "
      git add . >>  ${log_file}  2>&1 
      do_error_control "${?}" "" "" "4" "" "" ""
      cd ${actual}
    else 
      "EdEMessage" "1" ""
  fi 
  ############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	#################################################### 
}


function do_git_commit ()
{
  #|# Description :
  #|# This function performs a Git commit operation within a specified repository.
  #|# It creates a commit using an automated timestamp combined with a user-defined
  #|# commit message. The function is intended for integration within CAST automation
  #|# workflows to ensure consistent and traceable version control operations.
  #|#
  #|# Parameters :
  #|# ${1} : _repo_path
  #|#        Path to the target Git repository (Mandatory)
  #|#
  #|# ${2} : _commit_comment
  #|#        Custom message to include in the commit (Mandatory)
  #|#
  #|# Variables :
  #|# _repo_path        : Target repository directory
  #|# _commit_comment   : User-defined commit message
  #|# actual            : Stores the current working directory before context switch
  #|# repository        : Expected repository path (external/global variable dependency)
  #|#
  #|# Behavior :
  #|# - Validates input parameters using do_empty_var_control
  #|# - Saves the current working directory
  #|# - Checks repository availability (intended behavior)
  #|# - Switches to the repository directory
  #|# - Generates a commit message with timestamp and user input
  #|# - Executes `git commit`
  #|# - Performs error handling via do_error_control
  #|# - Restores the original working directory
  #|#
  #|# Commit Format :
  #|# automated commit YYYY-MM-DD-HH-MM-SS - <_commit_comment>
  #|#
  #|# Return / Output :
  #|# - No direct return value
  #|# - Emits CAST standardized messages
  #|# - Git commit output displayed on standard output
  #|#
  #|# Usage :
  #|# do_git_commit "/path/to/repository" "my commit message"
  #|#
  #|# Notes :
  #|# - Repository validation logic appears incorrect and should verify _repo_path
  #|# - Variable 'repository' is used but not defined locally (potential defect)
  #|# - Message calls "EdSMessage"/"EdEMessage" are not properly wrapped with set_message
  #|# - No check is performed for staged changes before commit
  #|#
  #|# Security / Compliance :
  #|# - Ensures traceability via timestamped commit messages
  #|# - Prevents execution with missing parameters
  #|# - Should validate repository path to avoid unintended execution context
  #|# - Commit operations should follow controlled branch and access policies
	############ STACK_TRACE_BUILDER #####################
	Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
	######################################################
  local _repo_path="${1}"
  local _commit_comment="${2}"

  do_empty_var_control "${_repo_path}".       "_repo_path"         "2" "1" "0"
  do_empty_var_control "${_commit_comment}"   "_commit_comment"    "2" "1" "0"

  set_message "check" "1" "entenring git directory"
  actual=$(pwd)
  if [[ -d ${core_functions_loaded}  ]]
    then 
      cd ${repository} 
      "EdSMessage" "1" ""

        set_message "check" "1" "generating commit "
        git commit -m "automated commit $(date +%Y-%m-%d-%H-%M-%S) - ${_commit_comment}" 
        do_error_control "${?}" "" "" "4" "" "" ""
      cd ${actual}
    else 
      "EdEMessage" "1" ""
  fi 
  ############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	#################################################### 
}


function do_git_push ()
{
  #|# Description :
  #|# This function pushes a local Git branch to the remote repository (origin)
  #|# and sets the upstream tracking reference. It is designed to automate the
  #|# publication of local changes within the CAST workflow, ensuring traceability
  #|# and centralized logging of Git operations.
  #|#
  #|# Parameters :
  #|# ${1} : _repo_path
  #|#        Path to the target Git repository (Mandatory)
  #|#
  #|# ${2} : _branche_name
  #|#        Name of the branch to push to the remote origin (Mandatory)
  #|#
  #|# Variables :
  #|# _repo_path     : Target repository directory
  #|# _branche_name  : Branch name to push
  #|# actual         : Stores the current working directory before context switch
  #|# repository     : Expected repository path (external/global dependency)
  #|# log_file       : CAST log file used to capture Git command output
  #|#
  #|# Behavior :
  #|# - Validates input parameters using do_empty_var_control
  #|# - Saves the current working directory
  #|# - Checks repository availability (intended behavior)
  #|# - Switches to the repository directory
  #|# - Executes `git push --set-upstream origin <branch>`
  #|# - Logs command output into the configured log file
  #|# - Performs error handling via do_error_control
  #|# - Restores the original working directory
  #|#
  #|# Return / Output :
  #|# - No direct return value
  #|# - Emits CAST standardized messages
  #|# - Writes Git push output to log file
  #|#
  #|# Usage :
  #|# do_git_push "/path/to/repository" "feature_branch"
  #|#
  #|# Notes :
  #|# - Branch name is prefixed with 'A' in current implementation (A${_branche_name})
  #|# - Repository validation logic appears incorrect and should validate _repo_path
  #|# - Variable 'repository' is used but not defined locally (potential defect)
  #|# - Message calls "EdSMessage"/"EdEMessage" are not properly wrapped with set_message
  #|# - No verification of remote existence or authentication state is performed
  #|#
  #|# Security / Compliance :
  #|# - Ensures traceability via centralized logging
  #|# - Prevents execution with missing parameters
  #|# - Requires valid Git authentication (SSH key or token)
  #|# - Should enforce branch naming and access policies in controlled environments
	############ STACK_TRACE_BUILDER #####################
	Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
	######################################################
  local _repo_path="${1}"
  local _branche_name="${2}"

  do_empty_var_control "${_repo_path}".       "_repo_path"         "2" "1" "0"
  do_empty_var_control "${_branche_name}"     "_branche_name"      "2" "1" "0"

  set_message "check" "1" "entenring git directory"
  actual=$(pwd)
  if [[ -d ${core_functions_loaded}  ]]
    then 
      cd ${repository} 
      "EdSMessage" "1" ""

      set_message "check" "1" "puching to ${_branche_name}"    
      git push --set-upstream origin A${_branche_name} >>  ${log_file}  2>&1 
      do_error_control "${?}" "" "" "4" "" "" ""
      cd ${actual}
    else 
      "EdEMessage" "1" ""
  fi 
  ############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	#################################################### 
}


function do_git_clone ()
{
  	#|# Description :
	#|# This function clones a Git repository into a specified directory.
	#|# It supports optional branch selection and integrates with the CAST
	#|# logging, error control, and stack trace mechanisms.
	#|#
	#|# Parameters :
	#|# ${1} : _repo_url
	#|#        URL of the Git repository to clone (Mandatory)
	#|#
	#|# ${2} : _path_to_clone
	#|#        Target directory where the repository will be cloned (Mandatory)
	#|#
	#|# ${3} : _branche_name
	#|#        Optional branch name to checkout during clone (Optional)
	#|#
	#|# Behavior :
	#|# - Updates the function call stack for traceability
	#|# - Validates required input variables using do_empty_var_control
	#|# - Prepares optional branch parameter if provided
	#|# - Ensures the target directory exists via set_new_directory
	#|# - Moves into the target directory context
	#|# - Executes git clone with optional branch
	#|# - Redirects output to the global log file
	#|# - Performs error handling via do_error_control
	#|# - Restores the initial working directory
	#|#
	#|# Dependencies :
	#|# - do_empty_var_control
	#|# - set_new_directory
	#|# - set_message
	#|# - do_error_control
	#|# - git (must be installed and accessible)
	#|#
	#|# Output :
	#|# - Cloned repository in the specified directory
	#|# - Logs written to ${log_file}
	#|#
	#|# Return :
	#|# - Standard exit code propagated via do_error_control
	############ STACK_TRACE_BUILDER #####################
	Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
	######################################################
  local _repo_url ="${1}"
  local _path_to_clone="${2}"
  local _branche_name="${3}"

  do_empty_var_control "${_repo_url }"        "_repo_url "         "2" "1" "0"
  do_empty_var_control "${_path_to_clone }"   "_path_to_clone "    "2" "1" "0"
  
  if [[ ! -z ${_branche_name} ]]  
     then 
         _branche_nam="-b ${_branche_nam}"
  fi
  
   set_new_directory "${_path_to_clone}"

  set_message "check" "1" "entenring cloning root"
  actual=$(pwd)
  if [[ -d ${_path_to_clone}  ]]
    then 
      cd ${repository} 
      "EdSMessage" "1" ""

      set_message "check" "1" "cloning to ${_repo_url} ${_branche_name} "    
      git clone ${_repo_url} ${_branche_name}  >>  ${log_file}  2>&1 
      do_error_control "${?}" "" "" "4" "" "" ""

      cd ${actual}
    else 
      "EdEMessage" "1" ""
  fi 
  ############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	#################################################### 
}



function do_commit_and_push()
{
  #|# Description :
  #|# This function performs a complete Git workflow by chaining add, commit,
  #|# and push operations on a target repository. It is designed to automate
  #|# standard version control actions within the CAST framework while ensuring
  #|# consistency and reuse of existing Git helper functions.
  #|#
  #|# Parameters :
  #|# ${1} : _repo_path
  #|#        Path to the target Git repository (Mandatory)
  #|#
  #|# ${2} : _commit_comment
  #|#        Commit message to use (Optional)
  #|#        If not provided, defaults to "Fully automated"
  #|#
  #|# ${3} : _branche_name
  #|#        Name of the branch to push to the remote origin (Mandatory)
  #|#
  #|# Variables :
  #|# _repo_path        : Target repository directory
  #|# _commit_comment   : Commit message (user-defined or default)
  #|# _branche_name     : Branch name to push
  #|#
  #|# Behavior :
  #|# - Validates mandatory parameters using do_empty_var_control
  #|# - Assigns a default commit message if none is provided
  #|# - Executes sequentially:
  #|#     → do_git_add       (stage all changes)
  #|#     → do_git_commit    (create commit with message)
  #|#     → do_git_push      (push branch to origin)
  #|# - Relies on underlying functions for logging and error handling
  #|#
  #|# Return / Output :
  #|# - No direct return value
  #|# - Emits CAST standardized messages via underlying functions
  #|# - Logs handled by called Git helper functions
  #|#
  #|# Usage :
  #|# do_commit_and_push "/path/to/repository" "my commit message" "feature_branch"
  #|# do_commit_and_push "/path/to/repository" "" "feature_branch"
  #|#
  #|# Notes :
  #|# - Commit message defaults to "Fully automated" when empty
  #|# - Depends on proper implementation of:
  #|#     → do_git_add
  #|#     → do_git_commit
  #|#     → do_git_push
  #|# - No explicit repository existence check is performed here
  #|# - Error handling is delegated to underlying functions
  #|#
  #|# Security / Compliance :
  #|# - Ensures traceability via standardized Git operations and logging
  #|# - Prevents execution with missing mandatory parameters
  #|# - Requires valid Git authentication (SSH key or token)
  #|# - Should comply with branch naming and commit policies in controlled environments
	############ STACK_TRACE_BUILDER #####################
	Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
	######################################################
  local _repo_path="${1}"
  local _commit_comment="${2}"
  local _branche_name="${3}"

  do_empty_var_control "${_repo_path}".       "_repo_path"       "2" "1" "0"
  do_empty_var_control "${_branche_name}"     "_branche_name"    "2" "1" "0"
  if [[ -z ${_commit_comment}  ]]
    then 
       _commit_comment="Fully automated"
  fi 
  

  do_git_add    "${_repo_path}" "."
  do_git_commit "${_repo_path}" "${_commit_comment}"
  do_git_push   "${_repo_path}" "${_branche_name}"



  ############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	#################################################### 
}

#|# this variable is used to check if the module is corectly loaded.
cast_git_module="true" 