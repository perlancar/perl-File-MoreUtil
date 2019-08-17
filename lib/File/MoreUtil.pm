package File::MoreUtil;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Cwd ();

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       file_exists
                       l_abs_path
                       dir_empty
                       dir_has_files
                       dir_has_dot_files
                       dir_has_non_dot_files
                       dir_has_subdirs
                       dir_has_dot_subdirs
                       dir_has_non_dot_subdirs
               );

our %SPEC;

sub file_exists {
    my $path = shift;

    !(-l $path) && (-e _) || (-l _);
}

sub l_abs_path {
    my $path = shift;
    return Cwd::abs_path($path) unless (-l $path);

    $path =~ s!/\z!!;
    my ($parent, $leaf);
    if ($path =~ m!(.+)/(.+)!s) {
        $parent = Cwd::abs_path($1);
        return undef unless defined($path);
        $leaf   = $2;
    } else {
        $parent = Cwd::getcwd();
        $leaf   = $path;
    }
    "$parent/$leaf";
}

sub dir_empty {
    my ($dir) = @_;
    return undef unless (-d $dir);
    return undef unless opendir my($dh), $dir;
    while (defined(my $e = readdir $dh)) {
        next if $e eq '.' || $e eq '..';
        return 0;
    }
    1;
}

sub dir_has_files {
    my ($dir) = @_;
    return undef unless (-d $dir);
    return undef unless opendir my($dh), $dir;
    while (defined(my $e = readdir $dh)) {
        next if $e eq '.' || $e eq '..';
        next unless -f "$dir/$e";
        return 1;
    }
    0;
}

sub dir_has_dot_files {
    my ($dir) = @_;
    return undef unless (-d $dir);
    return undef unless opendir my($dh), $dir;
    while (defined(my $e = readdir $dh)) {
        next if $e eq '.' || $e eq '..';
        next unless $e =~ /\A\./;
        next unless -f "$dir/$e";
        return 1;
    }
    0;
}

sub dir_has_non_dot_files {
    my ($dir) = @_;
    return undef unless (-d $dir);
    return undef unless opendir my($dh), $dir;
    while (defined(my $e = readdir $dh)) {
        next if $e eq '.' || $e eq '..';
        next if $e =~ /\A\./;
        next unless -f "$dir/$e";
        return 1;
    }
    0;
}

sub dir_has_subdirs {
    my ($dir) = @_;
    return undef unless (-d $dir);
    return undef unless opendir my($dh), $dir;
    while (defined(my $e = readdir $dh)) {
        next if $e eq '.' || $e eq '..';
        next unless -d "$dir/$e";
        return 1;
    }
    0;
}

sub dir_has_dot_subdirs {
    my ($dir) = @_;
    return undef unless (-d $dir);
    return undef unless opendir my($dh), $dir;
    while (defined(my $e = readdir $dh)) {
        next if $e eq '.' || $e eq '..';
        next unless $e =~ /\A\./;
        next unless -d "$dir/$e";
        return 1;
    }
    0;
}

sub dir_has_non_dot_subdirs {
    my ($dir) = @_;
    return undef unless (-d $dir);
    return undef unless opendir my($dh), $dir;
    while (defined(my $e = readdir $dh)) {
        next if $e eq '.' || $e eq '..';
        next if $e =~ /\A\./;
        next unless -d "$dir/$e";
        return 1;
    }
    0;
}

1;
# ABSTRACT: File-related utilities

=head1 SYNOPSIS

 use File::MoreUtil qw(
     file_exists
     l_abs_path
     dir_empty
     dir_has_files
     dir_has_dot_files
     dir_has_non_dot_files
     dir_has_subdirs
     dir_has_dot_subdirs
     dir_has_non_dot_subdirs
 );

 print "file exists" if file_exists("/path/to/file/or/dir");
 print "absolute path = ", l_abs_path("foo");
 print "dir exists and is empty" if dir_empty("/path/to/dir");


=head1 DESCRIPTION


=head1 FUNCTIONS

None are exported by default, but they are exportable.

=head2 file_exists

Usage:

 file_exists($path) => BOOL

This routine is just like the B<-e> test, except that it assume symlinks with
non-existent target as existing. If C<sym> is a symlink to a non-existing
target:

 -e "sym"             # false, Perl performs stat() which follows symlink

but:

 -l "sym"             # true, Perl performs lstat()
 -e _                 # false

This function performs the following test:

 !(-l "sym") && (-e _) || (-l _)

=head2 l_abs_path

Usage:

 l_abs_path($path) => STR

Just like Cwd::abs_path(), except that it will not follow symlink if $path is
symlink (but it will follow symlinks for the parent paths).

Example:

 use Cwd qw(getcwd abs_path);

 say getcwd();              # /home/steven
 # s is a symlink to /tmp/foo
 say abs_path("s");         # /tmp/foo
 say l_abs_path("s");       # /home/steven/s
 # s2 is a symlink to /tmp
 say abs_path("s2/foo");    # /tmp/foo
 say l_abs_path("s2/foo");  # /tmp/foo

Mnemonic: l_abs_path -> abs_path is analogous to lstat -> stat.

Note: currently uses hardcoded C</> as path separator.

=head2 dir_empty

Usage:

 dir_empty($dir) => BOOL

Will return true if C<$dir> exists and is empty.

This should be trivial but alas it is not. C<-s> always returns true (in other
words, C<-z> always returns false) for a directory.

=head2 dir_has_files

Usage:

 dir_has_files($dir) => BOOL

Will return true if C<$dir> exists and has one or more plain files in it. A
plain file is one that passes Perl's C<-f> operator. A symlink to a plain file
counts as a plain file. Non-plain files include named pipes, Unix sockets, and
block/character special files.

=head2 dir_has_dot_files

Usage:

 dir_has_dot_files($dir) => BOOL

Will return true if C<$dir> exists and has one or more plain dot files in it.
See L</dir_has_files> for the definition of plain files. Dot files a.k.a. hidden
files are files with names beginning with a dot.

=head2 dir_has_non_dot_files

Usage:

 dir_has_non_dot_files($dir) => BOOL

Will return true if C<$dir> exists and has one or more plain non-dot files in
it. See L</dir_has_dot_files> for the definitions. =head2 dir_has_subdirs

=head2 dir_has_subdirs

Usage:

 dir_has_files($dir) => BOOL

Will return true if C<$dir> exists and has one or more subdirectories in it.

=head2 dir_has_dot_subdirs

Usage:

 dir_has_dot_subdirs($dir) => BOOL

Will return true if C<$dir> exists and has one or more dot subdirectories (i.e.
subdirectories with names beginning with a dot) in it.

=head2 dir_has_non_dot_subdirs

Usage:

 dir_has_non_dot_subdirs($dir) => BOOL

Will return true if C<$dir> exists and has one or more non-dot subdirectories
(i.e. subdirectories with names not beginning with a dot) in it.


=head1 FAQ

=head2 Where is file_empty()?

For checking if some path exists, is a plain file, and is empty (content is
zero-length), you can simply use the C<-z> filetest operator.


=head1 SEE ALSO

L<App::FileTestUtils> includes CLI's for functions like L</dir_empty>, etc.

=cut
