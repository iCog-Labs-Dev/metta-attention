# Logger

This module is used by metta to add python implementations for writing
the values of the *attentionalFocus* space to a csv file which will be used to 
plot a diagram.

## Import

To import functions registered in this file in a metta file

```
!(import &self utils)
```

if the file has other imports make sure to use all the files

```
!(import! &self metta-attention:experiments:utils)
```

## Function usage

### save_params

This functions prints the parameteres used when the function is called to a json
file. This json file is used to get the **MAX_AF_SIZE** value when the system was
run last.

Addionally it manipulates the global parameteres **START_LOGGER** to true. The 
parameter is used to make the function responsible for writing to only write
on user request.

 ### get_csv_file_name

 This function can be used to create csv filnames based on time and date to 
 allow for running to different file on restart.

### write_to_csv

This function is used to write to a file passed in as argument. 
- Params
    - afatoms: An expression atom with structure ((atom STI) ....)
    - name: A string describing the file name starting from the location the 
    script is called from.

The function returns a Unit atom.
