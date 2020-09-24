# ==============================================================================
# Title         : score_exams.pl
# Description   : Solution for part 1b)
# Author        : Florian Thiévent
# Usage         : shuffle.pl <path to masterfile as txt> <list of filled out exams>
# How it works  : 1. load the file from the first cli arg
#
#                 Finish.
# ==============================================================================

use v5.32;

use List::Util qw(shuffle);
use Tie::File;
use Data::Dumper;
use File::Basename;
use File::Path qw( make_path );

# storage for correct answers and masterfile things
my @masterfile;
my @correct_answers;
my %answers;
my %questions;
my $current_question = 0;
my $num_exam_questions = 0;

# Use arrays to store the results for an exam
my @examfile;
my @correct_answered_questions;
my $current_exam_question = 0;
my %examquestions;
my $num_answered_questions = -1;
my $num_correct_questions = 0;
my @results;




die "need path to masterfile as first argument and list of exams as second argument\nUsage:\n  perl score_exams.pl correct_answers.txt exam1/student-*\n" if $#ARGV < 1 ;

tie @masterfile, 'Tie::File', @ARGV[0] or die "Cannot open Masterfile";
say "loaded masterfile @ARGV[0]";

# print Dumper(@masterfile)

for my $i (0..$#masterfile){

    if($masterfile[$i] =~ /^\d+\./){
        $current_question++;
        $questions{$current_question} = $masterfile[$i];
    }
    elsif( $masterfile[$i] =~  /\[\s*/x){
        if($masterfile[$i] =~  /\[[x,X]\]/){
            if( $current_question != 0){
                $answers{$current_question} = $masterfile[$i]
            }
        }
    }
}

say "All questions from masterfile";
for my $key(sort { $a <=> $b } keys %questions){
    print "$key => $questions{$key}\n";
}

say "All correct answers from masterfile";
for my $key(sort { $a <=> $b } keys %answers){
    print "$key => $answers{$key}\n";
    $num_exam_questions++;
}

untie @masterfile;

# now try it with an examfile. 
# First open the file and read all questions
# Check how many question where answered
# Check if the Questions are answered correct
# save stats to array
# print array
# -----------------------------------------------------------------
#                                  Name of file   Correct, Total
# Stats for a Student is a hash { "filename" => [ 7      , 20    ] }



my @files = @ARGV[1..$#ARGV];

for my $l(0..$#files){
    print "Checking file @files[$l]\n";

    tie @examfile, 'Tie::File', @files[$l] or die "Cannot open examfile @files[$l]";
     

    for my $i (0..$#examfile+1){

        
        if($examfile[$i] =~ /^.\d+\./){
        
            $current_exam_question++;
            $examquestions{$current_exam_question} = "-";
        }

        elsif( $examfile[$i] =~  /\[\s*/x){
            if( $current_exam_question != 0){
                if($examfile[$i] =~  /\[\s*[x,X]\s*\]/){
                    # ignore the answer from the intro head
                    my $answer = $examfile[$i];
                    $examquestions{$current_exam_question} = $examfile[$i];
                    
                } 
            }
        }
    }

   
    untie @examfile;

    say "All answers from examfile";
    for my $ekey(sort { $a <=> $b } keys %examquestions){
        print "$ekey => $examquestions{$ekey}\n";

        # Count all answered questions
        if($examquestions{$ekey} ne "-") {
            $num_answered_questions++;  
        }

        # Check all correct answered questions;
        if( lc $examquestions{$ekey} eq lc $answers{$ekey}){
            $num_correct_questions++;
        }

    }

    my $examname = substr($files[$l], rindex($files[$l], "/")+1, length($files[$l])-rindex($files[$l], "/")-1);


    my $grade = ($num_correct_questions *2)/10;

    if( $grade < 1.0){
        $grade = 1.0;
    }

    my $result = "$examname\t\t\t$num_correct_questions/$num_answered_questions\t\t\t$grade";
    push @results, $result;

    #reset all to init values
    @examfile = [];
    $current_exam_question = 0;
    %examquestions = {};
    $num_answered_questions = -1;
    $num_correct_questions = 0;
}

print "\n\nResults:\n";
print "Filename\t\t\t\t\t\t\tCorrect/Answered\tGrade\n";
print "==============================================================================================\n";
for my $d(0..$#results){
    print "@results[$d]\n";
}
