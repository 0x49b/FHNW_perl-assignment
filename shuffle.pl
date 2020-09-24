# ==============================================================================
# Title         : shuffle.pl
# Description   : Solution for part 1a)
# Author        : Florian Thiévent
# Usage         : shuffle.pl <path to masterfile as txt>
# How it works  : 1. load the file from the first cli arg 
#                 2. turn content of file into an array with tie
#                 3. copy input array to output array, to prevent changing the original
#                 4. step through output array and searching for a question. a question 
#                    starts with a digit followed by a period like 1.
#                 5. If a Question is found, create a new Hash in an array (possible_answers) to store the answers
#                 6. search for answers. an Answer starts with a [ and must be after a question
#                 7. if an answer is found, remove the solution marker (x or X) from within the square brackets and 
#                    add the line index to the possible answers array
#                 8. Now for all found possible answers, load the slice from the output array, shuffle the slice 
#                    and write it back to the output array
#                 9. Create the new filename from current time and date and the input filename
#                 10. Check if output path exists, if not, create it
#                 11. create a filehandler to write the content of the output array to a file
#                 12. write all lines and close the file.
#
#                 Finish.
# ==============================================================================

use v5.28;

use List::Util qw(shuffle);
use Tie::File;
use Data::Dumper;
use File::Basename;
use File::Path qw( make_path );


# "global" available arrays, vars, hashes
my @infile;
my @outfile;
my @possible_answers;

die "need path to masterfile as first argument" if $#ARGV < 0 ;

# load content of masterfile to input array
tie @infile, 'Tie::File', @ARGV[0] or die "Cannot open Masterfile";
say "loaded masterfile @ARGV";

#write input to output array, not to change the orginal file
@outfile = @infile;
# open tie for input
untie @infile;

say " Start reading content";
for my $i (0..$#outfile){

    if( $outfile[$i] =~  /^\d+\./){
            say " Found Question: $outfile[$i]";
            #Make empty array for answers
            push @possible_answers, {answers => []};
    } 
    elsif( $outfile[$i] =~  /\[\s*/x){
            #Remove answer mark x or X from possible answers
            say "   Found Answer: $outfile[$i]";
            $outfile[$i] =~ s/ \[ [x,X] /\[ /x;
            if($#possible_answers >=0 ){
                # add line index of answer to last added array of answers
                push $possible_answers[-1]->{answers}->@*, $i;
            }
        }
    
}

say "Shuffle Answers for Questions";
for(@possible_answers){
    @outfile[$_->{answers}->@*] = @outfile[ shuffle($_->{answers}->@*)];
}

say "Create new filename with pattern YYYYMMDD-HHMMSS prefixed";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $now = sprintf "%04d%02d%02d-%02d%02d%02d", $year+1900, $mon+1, $mday,$hour,$min,$sec;
my $input_filename = substr($ARGV[0], rindex($ARGV[0], "/")+1, length($ARGV[0])-rindex($ARGV[0], "/")-1);
my $new_filename = $now."-".$input_filename;

say "new filename is $new_filename";

my $dirname = dirname(__FILE__);
my $outpath = $dirname ."/out/";
my $outpathfile = $dirname ."/out/".$new_filename;

# Check output path
if ( !-d $outpath ) {
    make_path $outpath or die "Failed to create path: $outpath";
}

say "write new examfile to $outpath";


open(OUTFILE, ">> $outpathfile");
print OUTFILE @outfile;
close(OUTFILE);


say "finished creating new examfile. open it from $outpathfile";

