package main;
use strict;
use warnings;

use Test::More;
use Dancer::Test;

{
    use Dancer;
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
   
    timeout 0, 'get' => '/timeout0' => sub {
        sleep 1;
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

response_status_is [GET => '/timeout0'], 200, 
  "GET /success works (no timeout triggered)";
response_content_is [GET => '/timeout0'], 'ok', 
    "content looks good for /timeout0";


{
    use Dancer ;
    use Dancer::Plugin::TimeoutManager;
    setting show_errors => 1;

    eval{
        timeout 1, 'putt' => '/timeout_incorrect_method' => sub {
            sleep 1;
            return "ok";
        };
    };
    is $@, "method must be one in get, put, post, delete and putt is used as a method", "Exception is correctly detected on method"; 

}


done_testing;
1;

