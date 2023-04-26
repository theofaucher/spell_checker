#!/bin/bash

# Author : Théo FAUCHER 

denylist_files_name=()
dictionaries=()
custom_personal=/mnt/e/se2024-b2.doc/qualite/outils/detecteur_fautes/dictionaries/custom_personal.pws # Temporary file for building the custom dictionary
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONF_LOCATION="$SCRIPT_DIR/spell_checker.conf"

if [[ ! -e $CONF_LOCATION ]]; then
    echo -e "\033[31mError: the configuration file is not found.\033[0m"
    exit 1
else
    . $CONF_LOCATION
fi

nbr_lines=0

for dictionary in ${dictionaries[@]}
do
    if [[ ! -e $dictionary ]]; then
        echo -e "\033[31mError: the dictionary file $dictionary is not found.\033[0m"
        exit 1
    fi

    lines=$(sed -n '$=' $dictionary)
    nbr_lines=$(($nbr_lines + $lines))
done

echo "personal_ws-1.1 fr $nbr_lines utf-8" > "$custom_personal"

function cleanup() {
    rm $custom_personal
    exit 0
}

trap cleanup SIGINT

for dictionary in ${dictionaries[@]}
do
    tail -n +0 "$dictionary" >> "$custom_personal"
    sed -i -e '$a\' "$custom_personal"
done

tex_files=$(find $working_directory -type f -name '*.tex')

if [ -z "${tex_files[@]}" ]; then
    echo -e "\033[31mError: No tex files are found in the directory $working_directory.\033[0m"
    exit 1
fi

for tex_file in $tex_files
do
    tex_file_name=$(basename $tex_file)
    found_deny_file=false
    for denyfile in ${denylist_files_name[@]}
    do
        if [[ "$tex_file" == *"$denyfile"* && "$found_deny_file" = false ]]; then
            found_deny_file=true
            echo -e "\033[38;5;208mIgnored file: $tex_file_name\033[0m"
        fi
    done

    if [ "$found_deny_file" = false ]; then
        #tex_file_copy=`cat $tex_file`
        #tex_file_copy=$(echo "$tex_file_copy" | sed 's/\([?.!,¿]\)/ \1 /g')
        #tex_file_copy=$(echo "$tex_file_copy" | tr -s " ")
        #tex_file_copy=$(echo "$tex_file_copy" | sed 's/[^a-zA-Z?.!,¿]+/ /g')
        #echo $tex_file_copy >> temp.txt

        #words=$(<temp.txt aspell list --sug-mode=ultra --dont-skip-invalid-words --dont-clean-words --ignore-case --dont-tex-check-comments -p $custom_personal -t -d fr --encoding=utf-8)
        #rm temp.txt
        words=$(<$tex_file aspell list --sug-mode=ultra --dont-skip-invalid-words --dont-clean-words --ignore-case --dont-tex-check-comments -p $custom_personal -t -d fr --encoding=utf-8)
        for word in $words
        do
            word_line=$(grep -on "\<$word\>" $tex_file | head -n 1)
            line_number=$(echo "$word_line" | cut -d: -f1)

            if grep -qi "$word" $custom_personal; then
                found=true
            else
                found=false
            fi

            if [ "$found" = false ]; then
                echo  -e "\033[32mFile: $tex_file_name Line: $line_number: $word\033[0m"
                if [ "$stop_on_error" = true ]; then
                    echo -e "\033[38;5;208mSTOP ON ERROR ENABLE\033[0m"
                    exit 26
                fi
            fi
        done
    fi
done

rm $custom_personal