# ==============================================================================
# Title         : score_exams.pl
# Description   : Solution for part 1b), 2, 3
# Author        : Florian Thiévent
# Usage         : score_exams.pl <path to masterfile as txt> <list of filled out exams>
# How it works  : 1. load the masterfile from the first cli arg
#                 2. Extract all Questions and the right answers from masterfile
#                 3. Load an examfile
#                 4. load all answers to questions from the examfile, if no answer was given, it will be marked with a -
#                 5. compare the given answers to the correct answers from the masterfile
#                 6. make the stats and add them to stats array
#                 7. print out stats
#
#                 Finish.
# ==============================================================================

use v5.32;

use List::Util qw(shuffle);
use Tie::File;
use File::Basename;
use Data::Dumper;
use Math::Round;
use Text::Levenshtein qw(distance);
use Statistics::Lite qw(:all);

# storage for correct answers and masterfile things
my @masterfile;
my %answers;
my %questions;
my @allanswers;
my $current_question = 0;
my $num_exam_questions = 0;

# Use arrays to store the results for an exam
my @examfile;
my @exam_allanswers;
my @correct_answered_questions;
my $current_exam_question = 0;
my %examquestions;
my %checkquestions;
my $num_answered_questions = -1;
my $num_correct_questions = 0;
my @results;
my @report;
my %reps;

# stats array
my @stats_answered;
my @stats_correct;




die "need path to masterfile as first argument and list of exams as second argument\nUsage:\n  perl score_exams.pl correct_answers.txt exam1/student-*\n" if $#ARGV < 1 ;

tie @masterfile, 'Tie::File', @ARGV[0] or die "Cannot open Masterfile";
say "loaded masterfile @ARGV[0]";

for my $i (0..$#masterfile){

    if($masterfile[$i] =~ /^\d+\./){
        $current_question++;
        $questions{$current_question} = $masterfile[$i];
    }
    elsif( $masterfile[$i] =~  /\[\s*/x){
        # Get all Answers from Examfile to check against masterfile
        push @allanswers, $masterfile[$i];

        if($masterfile[$i] =~  /\[[x,X]\]/){
            if( $current_question != 0){
                $answers{$current_question} = $masterfile[$i]
            }
        }
    }
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
                
                # Get all Answers from Examfile to check against masterfile
                push @exam_allanswers, $examfile[$i];

                if($examfile[$i] =~  /\[\s*[x,X]\s*\]/){
                    # ignore the answer from the intro head
                    my $answer = $examfile[$i];
                    $examquestions{$current_exam_question} = $examfile[$i];
                    
                } 
            }
        }
    }

    untie @examfile;

    for my $ekey(sort { $a <=> $b } keys %examquestions){
       
        # Count all answered questions
        if($examquestions{$ekey} ne "-") {
            $num_answered_questions++;  
        }

        # Check all correct answered questions;
        if( lc $examquestions{$ekey} eq lc $answers{$ekey}){
            $num_correct_questions++;
        } else {

            # Using Levenshtein Distance to chek if it uses less than 10% difference
            my $normal_master       = normalizeAnswer($answers{$ekey});
            my $normal_master_len   = length $normal_master;
            my $normal_answer       = normalizeAnswer($examquestions{$ekey});
            my $normal_answer_len   = length $normal_answer;
            my $distance            = distance($normal_answer, $normal_master);
            my $tpercent            = round($normal_master_len * 0.1);

            if($distance > 0){
                if($distance < $tpercent){
                    $num_correct_questions++;

                    print "$distance $tpercent\n";
                    makeReport(getExamname(@files[$l]), "Missing question: " . smallTrim($answers{$ekey}));
                    makeReport(getExamname(@files[$l]), "Used this instead: " . smallTrim($examquestions{$ekey}));

                }
            }

        }
    }

    my $examname = getExamname($files[$l]);


    my $grade = ($num_correct_questions *2)/10;

    if( $grade < 1.0){
        $grade = 1.0;
    }

    my $result = "$examname\t\t\t$num_correct_questions/$num_answered_questions\t\t\t$grade";
    push @results, $result;
    push @stats_answered, $num_answered_questions;
    push @stats_correct, $num_correct_questions;


    #reset all to init values
    @examfile = [];
    $current_exam_question = 0;
    %examquestions = {};
    $num_answered_questions = -1;
    $num_correct_questions = 0;
}


printResults();




# subs needed for convenience :-)
sub smallTrim(){
    my ($string) = @_;
    $string =~ s/\[\s*[x,X]\s*\]/ /;
    $string =~ s/^\s+//;
    return $string;
}

sub getExamname(){
    my ($path) = @_;
    return substr($path, rindex($path, "/")+1, length($path)-rindex($path, "/")-1);
}

sub normalizeAnswer(){
    my ($answer) = @_;


    # step 1 - make string all lowercase
    lc $answer;

    # step 2 - remove stopwords [https://stackoverflow.com/questions/26820340/perl-remove-stopwords-from-string]
    my @stopList = (" the ", " a ", " an ", " of ", " and ", " on ", " in ", " by ", " with ", " at ", " after ", " into ", " their ", " is ",  " that ", " they ", " for ", " to ", " it ", " them ", " which ");
    my ($rx) = map qr/(?:$_)/, join "|", map qr/\b\Q$_\E\b/, @stopList;
    $answer =~ s/$rx//g;

    $answer =~ s/\[\s*[x,X]\s*\]/ /;
    
    # step 3 - remove whitespaces at the start/end of string
    $answer =~ s/^\s+|\s+$//g;

    # step 4 - replace all sequences of whitespace with a single whitespace
    $answer =~ s/\s+/ /g; 

    return $answer;
}

# Push report entries 
sub makeReport(){
    my ($file, $entry) = @_;
    if(exists($reps{$file})){       
        my @temp = $reps{$file};
        push @temp, $entry;
        $reps{$file} = [@temp];
    } else {
        $reps{$file} = ($entry);
    }

}

sub printStats(){

    my $min_answered = round min(@stats_answered);
    my $max_answered = round max(@stats_answered);
    my $average_answered = round mean(@stats_answered);
    my %freq_answered = frequencies(@stats_answered);

    my $min_correct = round min(@stats_correct);
    my $max_correct = round max(@stats_correct);
    my $average_correct = round mean(@stats_correct);
    my %freq_correct = frequencies(@stats_correct);

    print "\nStats:\n";
    print "\tAverage number of questions answered....$average_answered\n";
    print "\t                             Minumum....$min_answered ($freq_answered{$min_answered}".(($freq_answered{$min_answered}>1)?" students":" student").")\n";
    print "\t                             Maximum....$max_answered ($freq_answered{$max_answered}".(($freq_answered{$max_answered}>1)?" students":" student").")\n";
    print "\n";
    print "\tAverage number of correct answers.......$average_correct\n";
    print "\t                          Minumum.......$min_correct ($freq_correct{$min_correct}".(($freq_correct{$min_correct}>1)?" students":" student").")\n";
    print "\t                          Maximum.......$max_correct ($freq_correct{$max_correct}".(($freq_correct{$max_correct}>1)?" students":" student").")\n";

}

sub printResults(){
    print "\n\nResults:\n\n";
    print "\tFilename\t\t\t\t\t\t\tCorrect/Answered\tGrade\n";
    print "\t==============================================================================================\n";
    for my $d(0..$#results){
        print "\t@results[$d]\n";
    }
    print "\t==============================================================================================\n";
    print "\nReport:\n";

    for my $key( keys %reps){
        print "\n\t$key:\n";

        for my $elem (@{$reps{$key}}){
            print "\t\t$elem\n";
        }
    }

    printStats();

    print "=========> Done <=========\n";

}