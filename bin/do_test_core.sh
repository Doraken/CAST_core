#!/bin/bash 
# script permettant le test de toute les fonction de la core lib et de valider leur fonctionnement. 

# definition de la racine de la stack trace
Function_PATH="/"
# definition de la racine du projet
root_path="$(dirname $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd))"
# log date time file
log_timestamp=$(date '+%Y-%m-%d_%H_%M_%S')
# log file path
log_file="${root_path}/log/dev_init_${log_timestamp}.log"
#help file path
help_file="${root_path}/help/$( echo ${BASH_SOURCE} | awk -F\/ '{print $NF }' | sed 's/\.sh//g' ).txt"
# fichier de configuration de git
git_mapping_file="${root_path}/config/repositories_mapping.env"

global_configuration_file="${root_path}/config/global.env"

clear

if [ -f "${global_configuration_file}" ]
  then
    echo "🔧 Chargement de la configuration depuis global.env..."
    source "${global_configuration_file}"
	else
    echo "❌ Erreur: fichier ${global_configuration_file} introuvable"
    exit 1
fi

echo "Loading core functions..."
if [[ ${core_functions_loaded} -ne 1 ]]
  then
  	echo "Core functions not loaded, loading now..."
	  . ${root_path}/lib/core.sh
	else
		echo "Core functions already loaded, skipping..."
fi

set_new_directory "${root_path}/log"

set_console_line

set_message "check" "0" "ceci en un message test reussi ..................."
set_message "EdSMessage" "0" ""

set_message "check" "0" "ceci en un message test warning .................."
set_message "EdWMessage" "0" ""

set_message "check" "0" "ceci en un message test erreur non fatale  ......."
set_message "EdEMessage" "0" "" 

set_message "info" "0" "ceci en un message d'info  ........................"

set_console_line



print_header "starting directory path tests " 
set_message "info" "0" "Function testdo_check_dir_null_or_slash testing /tmp  ......."
set_spacer_message

set_message "info" "0" "Function testdo_check_dir_null_or_slash testing /tmp external ......."
set_console_line

do_check_dir_null_or_slash "/tmp" "1"
set_console_line
set_spacer_message

set_message "info" "0" "Function testdo_check_dir_null_or_slash testing /tmp internal ......."
set_console_line
do_check_dir_null_or_slash "/tmp" "0"
set_console_line


set_spacer_message
set_message "info" "0" "testdo_check_dir_null_or_slash de / ......................."
set_spacer_message

set_console_line
do_check_dir_null_or_slash "/" "1" "1"
set_console_line
set_spacer_message


set_message "info" "0" "testdo_check_dir_null_or_slash de null ......................."
set_spacer_message

set_console_line
do_check_dir_null_or_slash "" "1" "1"
set_console_line

print_header "starting directory create tests " 

set_spacer_message
set_message "info" "0" "./test directory not present  ......."

set_console_line
set_new_directory "./test" "0"
set_console_line

set_spacer_message
set_message "info" "0" "./test directory  present  ......."


set_console_line
set_new_directory "./test" "0"
set_console_line
rmdir ./test 



print_header "starting error controle function test " 

set_message "info" "0" "testing sucess  ......."

set_console_line
do_error_control "0" "Operation completed successfully"
set_console_line

set_spacer_message
set_message "info" "0" "testing error  ......."

set_console_line
do_error_control "1" "with completion message" "0" "1" "error control function autotesting" 
set_console_line

set_console_line
do_error_control "0" "with completion message" "0" "1" "error control function autotesting" 
set_console_line


print_header "starting empty var control function test " 
set_spacer_message

set_message "info" "0" "Function do_empty_var_control testing as external ......."
set_console_line

do_empty_var_control "${my_var}" "my_var" "2" "1" "1"
set_console_line
my_var="something" 
do_empty_var_control "${my_var}" "my_var" "2" "1" "1"
set_console_line
set_spacer_message

set_message "info" "0" "Function do_empty_var_control testing as internal ......."
set_console_line
set_message "info" "0" "Function do_empty_var_control with empty var ......."
do_empty_var_control "${my_var2}" "my_var2" "2" "0" "1"
set_console_line
my_var2="something" 
set_message "info" "0" "Function do_empty_var_control with not empty var ( blank result )......."
do_empty_var_control "${my_var2}" "my_var2" "2" "0" "1"
set_console_line


 
echo "---end test "




 