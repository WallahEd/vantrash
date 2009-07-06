#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use App::VanTrash::Controller;

App::VanTrash::Controller->new(
    http_module => 'ServerSimple',
    http_args => {
        port => 2009, 
        host => 'localhost',
        net_server => 'Net::Server::PreForkSimple',
        net_server_configure => {
            max_servers  => 5,
            max_requests => 100,
        },
    },
    base_path => "$FindBin::Bin/..",
)->run;
exit;
