#!/bin/bash
#
# to install code_uml
# dart pub global activate code_uml


# copy source code to a temp folder
rm -rf temp
mkdir temp
cp -r ../../dart_network_layer_dio/lib temp
cp -r ../../dart_network_layer_core/lib temp

# fund absolute path of the temp folder
TEMP_FOLDER=$(pwd)

code_uml --from="$TEMP_FOLDER/temp" --to="$TEMP_FOLDER" --uml=mermaid


