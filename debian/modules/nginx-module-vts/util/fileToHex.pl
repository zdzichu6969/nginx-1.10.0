#! /usr/bin/env perl
#
# @file:    fileToHex.pl
# @brief:
# @author:  YoungJoo.Kim <vozltx@gmail.com>
# @version:
# @date:

package FileToHex;

use strict;
use Carp;

sub new{
    my($class, %cnf) = @_;

    my $path = delete $cnf{path};
    my $handle = delete $cnf{handle};

    my $self =
    bless {
        path    => $path,
        handle  => $handle
    }, $class;

    return bless $self;
}

sub __exit {
    my $self = shift if ref ($_[0]);
    my $res = shift;
    Carp::carp __PACKAGE__ . ": $res->{string}";
    exit($res->{return} || 1);
}

sub fileOpen {
    my $self = shift if ref ($_[0]);
    my $path = shift || $self->{path};
    $path = $self->{path} unless defined $path;
    (defined $path && -e $path) || $self->__exit({string => "error: [$path] is not defined or exists!"});
    open(my $handle, "<", $path) || $self->__exit({string => "error: open(): $!"});
    $self->{handle} = $handle;
    return $self->{handle};
}

sub fileClose {
    my $self = shift if ref ($_[0]);
    my $handle = shift || $self->{handle};
    $handle && close($handle);
}

sub fileReadByte {
    my $self = shift if ref ($_[0]);
    my $buf = \shift;
    my $byte = shift || 1;
    my $handle = shift || $self->{handle};
    return read($handle, $$buf, $byte);
}

sub DESTROY {
    my $self = shift if ref ($_[0]);
    $self->fileClose();
}

1;

package main;

if ($#ARGV < 0) {
    print "Usage: $0 {path} {max}\n";
    exit(2);
}

my $path = $ARGV[0];
my $max = $ARGV[1] || 16;
my $fth = FileToHex->new(path => $path);
$fth->fileOpen();
my $buf = "";
my $i = 0;
while($fth->fileReadByte(my $c)) {
    $i++;
    $buf .= '\x' . unpack("H2", $c);
    if (!($i % $max)) {
        print "\"$buf\" \\\n";
        $buf = "";
    }
}
print "\"$buf\"\n" if (length($buf));
$fth->fileClose();

# vi:set ft=perl ts=4 sw=4 et fdm=marker:
