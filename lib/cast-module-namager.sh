# ==============================================================================
#|# Script Name    : cast-module-namager.sh
#|# Framework      : CAST - Common Application Scripting Toolkit
#|# Component      : GIT function Initialization
#|# Version        : 0.1.0
#|# Author         : Arnaud Crampet
#|# mail           : arnaud@crampet.net
#|# Creation Date  : 2026-01-20
#|# Last Update    : 2026-04-30
#|# License        : GNU GPL 2.0
# ==============================================================================
#|# Describe : this is a lib used for module managment



function do_load_module() 
{
  #|# Description :
  #|# This function dynamically loads a CAST module from the lib directory and
  #|# validates its activation using a control variable (module key).
  #|#
  #|# Behavior :
  #|# - Validates input parameters (_module_name and _module_key)
  #|# - Builds the expected module path using root_path
  #|# - Checks if the module file exists
  #|# - Sources the module file into the current shell context
  #|# - Retrieves the value of the module activation key dynamically
  #|# - Validates that the module is correctly initialized (key == "true")
  #|# - Emits success or error messages accordingly
  #|#
  #|# Parameters :
  #|# ${1} : _module_name
  #|#        Name of the module to load (used to build the filename cast-<module>.sh)
  #|#
  #|# ${2} : _module_key
  #|#        Name of the variable defined inside the module used to validate successful loading
  #|#
  #|# Dependencies :
  #|# - do_empty_var_control : validates input variables
  #|# - set_message          : logging and status handling
  #|# - root_path            : base path of the CAST framework
  #|#
  #|# Expected module behavior :
  #|# - The sourced module must define a variable (named by _module_key)
  #|# - This variable must be set to "true" if initialization is successful
  #|#
  #|# Error Handling :
  #|# - If required parameters are missing → exit via do_empty_var_control
  #|# - If module file does not exist → function silently exits (no action)
  #|# - If module key is not "true" → emits EdEMessage with code 100
  #|#
  #|# Security Considerations :
  #|# - Uses 'source' (.) which executes code in current shell context
  #|# - Uses 'eval' to resolve dynamic variable name → ensure trusted module sources
  #|#
  #|# Example :
  #|# do_load_module "network" "NETWORK_MODULE_ENABLED"
  #|#
  #|# Send Back :
  #|# - Loads module into current shell context if valid
  #|# - Emits status messages (success or failure)
  local _module_name="${1}" 
  local _module_key="${2}"

  do_empty_var_control "${_module_name}".   "_module_name"   "2" "0" "0"
  do_empty_var_control "${_module_key}"     "_module_key"    "2" "0" "0"

  local _full_path_module="${root_path}/lib/cast-${_module_name}.sh"

  if [[ -f ${_full_path_module} ]]
    then 
      set_message "check" "0" "Trying to activate the module ${_module_name} cast" 
      . ${_full_path_module}
      eval local _module_val_key=\$${_module_key}
      if [[ ${_module_val_key} = "true"  ]]
        then 
          set_message "EdSMessage" "0"    "" 
        else 
          set_message "EdEMessage" "100" "" 
      fi
  fi
}

MODULE_MANAGER="true"