```
                              $$\          $$$$$$\  $$\                     $$\ 
                              $$ |        $$  __$$\ \__|                    $$ |
 $$$$$$\   $$$$$$\   $$$$$$\  $$ |        $$ /  \__|$$\ $$$$$$$\   $$$$$$\  $$ |
$$  __$$\ $$  __$$\ $$  __$$\ $$ |$$$$$$\ $$$$\     $$ |$$  __$$\  \____$$\ $$ |
$$ /  $$ |$$$$$$$$ |$$ |  \__|$$ |\______|$$  _|    $$ |$$ |  $$ | $$$$$$$ |$$ |
$$ |  $$ |$$   ____|$$ |      $$ |        $$ |      $$ |$$ |  $$ |$$  __$$ |$$ |
$$$$$$$  |\$$$$$$$\ $$ |      $$ |        $$ |      $$ |$$ |  $$ |\$$$$$$$ |$$ |
$$  ____/  \_______|\__|      \__|        \__|      \__|\__|  \__| \_______|\__|
$$ |                                                                            
$$ |                                                                            
\__|                                                            
```
# Final Assignment

Repository for the final project for the FHNW Course Introduction to Perl for Programmers.
Author: Florian Thiévent

## Used Modules from CPAN
* Text::Levenshtein
* Statistics::Lite
* Math::Round

## Implemented Tasks

| Task  | File            | Usage                                                                             | Remarks                                       |
| ----- | --------------- | --------------------------------------------------------------------------------- | --------------------------------------------- |
| 1a    | shuffle.pl      | ``` perl shuffle.pl <path to masterfile as txt> ```                               |                                               |
| 1b    | score_exams.pl  | ``` perl score_exams.pl <path to masterfile as txt> <list of filled out exams>``` | Exams can be list like exam1/file-*.txt       |
| 2     | score_examps.pl | ``` perl score_exams.pl <path to masterfile as txt> <list of filled out exams>``` | Marked in File where this part is implemented |
| 3     | score_examps.pl | ``` perl score_exams.pl <path to masterfile as txt> <list of filled out exams>``` | Parts implemented                             |
|       |                 |                                                                                   |                                               |


### Function of 1a
1. load the file from the first cli arg 
2. turn content of file into an array with tie
3. copy input array to output array, to prevent changing the original
4. step through output array and searching for a question. a question starts with a digit followed by a period like 1.
5. If a Question is found, create a new Hash in an array (possible_answers) to store the answers
6. search for answers. an Answer starts with a [ and must be after a question
7. if an answer is found, remove the solution marker (x or X) from within the square brackets and add the line index to the possible answers array
8. Now for all found possible answers, load the slice from the output array, shuffle the slice and write it back to the output array
9. Create the new filename from current time and date and the input filename
10. Check if output path exists, if not, create it
11. create a filehandler to write the content of the output array to a file
12. write all lines and close the file.

### Function of 1b, 2, 3
1. load the masterfile from the first cli arg
2. Extract all Questions and the right answers from masterfile
3. Load an examfile
4. load all answers to questions from the examfile, if no answer was given, it will be marked with a -
5. compare the given answers to the correct answers from the masterfile
6. make the stats and add them to stats array
7. print out stats