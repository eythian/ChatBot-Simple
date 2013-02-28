#!/usr/bin/perl

use strict;
use warnings;

# this example shows how to organize data in a separate package
# and how to set topics, memorize stuff, etc.

package SmallTalk;

use ChatBot::Simple;

no warnings 'uninitialized';

my %mem;

transform 'hello' => 'hi';

pattern 'hi' => sub {
  my ($input, $param) = @_;
  if (!$mem{name}) {
    $mem{topic} = 'name';
    return "hi! what's your name?";
  }
  return;
};

pattern "my name is :name" => sub {
  my ($input,$param) = @_;
  $mem{name} = $param->{':name'};
  $mem{topic} = 'how_are_you';
  return "Hello, :name! How are you?";
};

transform 'goodbye', 'bye-bye', 'sayonara' => 'bye';

pattern 'bye' => 'bye!';

pattern 'fine' => 'great!';

pattern qr{^(\w+)$} => sub {
  my ($input,$param) = @_;
  if ($mem{topic} eq 'name') {
    $mem{name} = $param->{1};
    $mem{topic} = 'how_are_you';
    return "Hello, $mem{name}! How are you?";
  }
  return;
} => "I don't understand that!";


package Calculator;

use ChatBot::Simple;

no warnings 'uninitialized';

pattern qr{(\d+)\s*([\+\-\*\/])\s*(\d+)} => sub {
  my ($input,$param) = @_;
  my ($n1,$op,$n2) = ($param->{1},$param->{2},$param->{3});

  my $result = 
        $op eq '+' ? $n1 + $n2
      : $op eq '-' ? $n1 - $n2
      : $op eq '*' ? $n1 * $n2
      : $op eq '/' ? $n1 / $n2
                   : "I don't know how to calculate that!";

  # problem: if we type "1 + 1", the result will be "+"
  # which is the second parameter ($param->{2}) in the regexp.
  #
  # we'll probably have to use a prefix like ':1', ':2', ':3'
  # to avoid confusion.
  #
  # that's also a good reason to keep the ':' before named parameters,
  # so we don't replace words that happen to coincide with parameter
  # names.
  #
  # alternatively, we could create accessors (param('var') returns
  # $param->{':var'}, and so on

  return "$n1 $op $n2 = $result";
};

##### MAIN LOOP ######

package main;

use ChatBot::Simple;

print "> ";
while (my $input = <>) {
  chomp $input;

  my $response = ChatBot::Simple::process($input);

  print "$response\n\n> ";
}