# ==============================================================================
# Title         : score_exams.pl
# Description   : Solution for part 1b)
# Author        : Florian Thiévent
# Usage         : shuffle.pl <path to masterfile as txt> <list of filled out exams>
# How it works  : 1. load the file from the first cli arg
#
#                 Finish.
# ==============================================================================

use v5.28;

use List::Util qw(shuffle);
use Tie::File;
use Data::Dumper;
use File::Basename;
use File::Path qw( make_path );

# storage for correct answers and masterfile things
my @masterfile;
my @correct_answers;
my %questions;
my $current_question = 0;

# Use arrays to store the results for an exam
my @student_results;
my @answered_question;
my @correct_answered_questions;

die "need path to masterfile as first argument and list of exams as second argument\nUsage:\n  perl score_exams.pl correct_answers.txt exam1/student-*\n" if $#ARGV < 1 ;

tie @masterfile, 'Tie::File', @ARGV[0] or die "Cannot open Masterfile";
say "loaded masterfile @ARGV[0]";

# print Dumper(@masterfile)

for my $i (0..$#masterfile){

    if($masterfile[$i] =~ /^\d+\./){
        $current_question++;
    }
    elsif( $masterfile[$i] =~  /\[\s*/x){
        if($masterfile[$i] =~  /\[[x,X]\]/){
            if( $current_question != 0){
                $questions{$current_question} = $masterfile[$i]
            }
        }
    }
}

say "All correct answers from masterfile";
for my $key(sort { $a <=> $b } keys %questions){
    print "$key => $questions{$key}\n";
}


#now try it with 