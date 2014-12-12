package main;
use strict;
use warnings;

use Test::More;
use Dancer::Test;

{
use Dancer ;
    use Dancer::Plugin::TimeoutManager;
    setting show_errors => 1;

    timeout 2, 'get' => '/success' => sub {
        sleep 1;
        return "ok";
    };

    timeout 2, 'get' => '/fail' => sub {
        sleep 3;
        return "ok";
    };
}

response_status_is [GET => '/success'], 200, 
  "GET /success works (no timeout triggered)";
response_content_is [GET => '/success'], 'ok', 
    "content looks good for /success";

response_status_is [GET => '/fail'], 408, 
  "GET /fail works (timeout triggered)";
response_content_like [GET => '/fail'], 
    qr{Request Timeout.*2 seconds}, 
    "content looks good for /fail";


done_testing;
1;

