# Spell checker

This tool displays spelling errors present in all the tex files of a directory. It runs with [Aspell](http://aspell.net/) and additional dictionaries. 

## Installation

- Install aspell, sed aspell-XX (language: aspell-fr, aspell-en, ...)
- Install with apt `sudo apt install aspell aspell-fr sed`
- Assign an execute permission to the script `chmod +x spell_checker.sh`

## Configuration

Specify the path of the directory to be analyzed in the "working_directory" variable.

If you want a customised dictionary:
- Create a file (no specific extension).
- Add the words you want to be filtered.
- Add the path of the custom dictionary in the "dictionaries" variable of the configuration file.
- You can add as many custom dictionaries as you require.
- The case of words is ignored.

If you want to add a file to the deny list (A list of files that will not be check):
- In the configuration file, in the "denylist_files_name" variable, add the entire name or a part of the name of the file(s) you want to block.

If the "stop_on_error" variable is true, the tool will stop on the first detected error.

## How to run

`./spell_checker.sh`

# Example:

spell_checker.conf: 
```
working_directory=/home/<user>/<directory to be checked>/

dictionaries+=("<script directory path>/dictionaries/dictionary_example.txt")

denylist_files_name+=(description-)
stop_on_error=false
```

Dictionary exemple: dictionary_example.txt
```
IdEcran
IdScreen
IdDevices
IdRadiateur
IdHeater
IdLampe
IdLight
```

Normal execution:

```bash
$ ./spell_checker.sh
File: acronyms.tex Line: 8: ddéfinie
File: glossary.tex Line: 140: potentionmètre
Ignored file: files_ignored-MAE-tester.tex
Ignored file: files_ignored-MAE-uiSHM.tex
File: tablesVersion.tex Line: 58: dictionaire
```

Dictionary file is not found:
```bash
$ ./spell_checker.sh
Error: the dictionary file <script directory path>/dictionaries/dictionaryExample.txt is not found.
```

Tex files are not found:
```bash
$ ./spell_checker.sh
Error: No tex files are found in the directory /home/<user>/<directory to be checked>/.
```

Configuration file is not found:
```bash
$ ./spell_checker.sh
Error: the configuration file is not found.
```

## Contribution

Feel free to suggest a change. If you see an error / a problem, you can submit a correction