#!perl

use 5.010001;
use strict;
use warnings;
use Test::More 0.98;

use Cwd qw(abs_path);
use File::chdir;
use File::Slurper qw(write_text);
use File::Spec;
use File::MoreUtil qw(file_exists l_abs_path dir_empty dir_has_files dir_has_dot_files dir_has_non_dot_files dir_has_subdirs dir_has_dot_subdirs dir_has_non_dot_subdirs);
use File::Temp qw(tempfile tempdir);

subtest file_exists => sub {
    plan skip_all => "symlink() not available"
        unless eval { symlink "", ""; 1 };

    my ($fh1, $target)  = tempfile();
    my ($fh2, $symlink) = tempfile();

    ok(file_exists($target), "existing file");

    unlink($symlink);
    symlink($target, $symlink);
    ok(file_exists($symlink), "symlink to existing file");

    unlink($target);
    ok(!file_exists($target), "non-existing file");
    ok(file_exists($symlink), "symlink to non-existing file");

    unlink($symlink);
};

subtest l_abs_path => sub {
    plan skip_all => "symlink() not available"
        unless eval { symlink "", ""; 1 };

    my $dir = abs_path(tempdir(CLEANUP=>1));
    local $CWD = $dir;

    mkdir("tmp");
    write_text("tmp/file", "");
    symlink("file", "tmp/symfile");
    symlink("$dir/tmp", "tmp/symdir");
    symlink("not_exists", "tmp/symnef"); # non-existing file
    symlink("/not_exists".rand()."/1", "tmp/symnep"); # non-existing path

    is(  abs_path("tmp/file"   ), "$dir/tmp/file"   , "abs_path file");
    is(l_abs_path("tmp/file"   ), "$dir/tmp/file"   , "l_abs_path file");
    is(  abs_path("tmp/symfile"), "$dir/tmp/file"   , "abs_path symfile");
    is(l_abs_path("tmp/symfile"), "$dir/tmp/symfile", "l_abs_path symfile");
    is(  abs_path("tmp/symdir" ), "$dir/tmp"        , "abs_path symdir");
    is(l_abs_path("tmp/symdir" ), "$dir/tmp/symdir" , "l_abs_path symdir");
    is(  abs_path("tmp/symnef" ), "$dir/tmp/not_exists", "abs_path symnef");
    is(l_abs_path("tmp/symnef" ), "$dir/tmp/symnef" , "l_abs_path symnef");
    ok(! abs_path("tmp/symnep" ), "abs_path symnep");
    is(l_abs_path("tmp/symnep" ), "$dir/tmp/symnep" , "l_abs_path symnep");
};

subtest "dir_empty, dir_has_*files, dir_has_*subdirs" => sub {
    my $dir = tempdir(CLEANUP=>1);
    local $CWD = $dir;

    mkdir "empty", 0755;

    mkdir "hasfiles", 0755;
    write_text("hasfiles/1", "");

    mkdir "hasdotfiles", 0755;
    write_text("hasdotfiles/.1", "");

    mkdir "hasdotdirs", 0755;
    mkdir "hasdotdirs/.1";

    mkdir "unreadable", 0000;

    mkdir "hassubdirs", 0755;
    mkdir "hassubdirs/d1", 0755;

    mkdir "hasdotsubdirs", 0755;
    mkdir "hasdotsubdirs/.d1", 0755;

    ok( dir_empty("empty"));
    ok(!dir_empty("doesntexist"));
    ok(!dir_empty("hasfiles"));
    ok(!dir_empty("hasdotfiles"));
    ok(!dir_empty("hasdotdirs"));
    ok(!dir_empty("unreadable")) if $>;

    ok(!dir_has_files("empty"));
    ok(!dir_has_files("doesntexist"));
    ok( dir_has_files("hasfiles"));
    ok( dir_has_files("hasdotfiles"));
    ok(!dir_has_files("hassubdirs"));
    ok(!dir_has_files("hasdotsubdirs"));

    ok(!dir_has_dot_files("empty"));
    ok(!dir_has_dot_files("doesntexist"));
    ok(!dir_has_dot_files("hasfiles"));
    ok( dir_has_dot_files("hasdotfiles"));
    ok(!dir_has_dot_files("hassubdirs"));
    ok(!dir_has_dot_files("hasdotsubdirs"));

    ok(!dir_has_non_dot_files("empty"));
    ok(!dir_has_non_dot_files("doesntexist"));
    ok( dir_has_non_dot_files("hasfiles"));
    ok(!dir_has_non_dot_files("hasdotfiles"));
    ok(!dir_has_non_dot_files("hassubdirs"));
    ok(!dir_has_non_dot_files("hasdotsubdirs"));

    ok(!dir_has_subdirs("empty"));
    ok(!dir_has_subdirs("doesntexist"));
    ok(!dir_has_subdirs("hasfiles"));
    ok(!dir_has_subdirs("hasdotfiles"));
    ok( dir_has_subdirs("hassubdirs"));
    ok( dir_has_subdirs("hasdotsubdirs"));

    ok(!dir_has_subdirs("empty"));
    ok(!dir_has_subdirs("doesntexist"));
    ok(!dir_has_subdirs("hasfiles"));
    ok(!dir_has_subdirs("hasdotfiles"));
    ok( dir_has_subdirs("hassubdirs"));
    ok( dir_has_subdirs("hasdotsubdirs"));

    ok(!dir_has_dot_subdirs("empty"));
    ok(!dir_has_dot_subdirs("doesntexist"));
    ok(!dir_has_dot_subdirs("hasfiles"));
    ok(!dir_has_dot_subdirs("hasdotfiles"));
    ok(!dir_has_dot_subdirs("hassubdirs"));
    ok( dir_has_dot_subdirs("hasdotsubdirs"));

    ok(!dir_has_non_dot_subdirs("empty"));
    ok(!dir_has_non_dot_subdirs("doesntexist"));
    ok(!dir_has_non_dot_subdirs("hasfiles"));
    ok(!dir_has_non_dot_subdirs("hasdotfiles"));
    ok( dir_has_non_dot_subdirs("hassubdirs"));
    ok(!dir_has_non_dot_subdirs("hasdotsubdirs"));
};

DONE_TESTING:
done_testing();
