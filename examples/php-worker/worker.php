<?php

declare(strict_types=1);

require __DIR__ . '/vendor/autoload.php';

use Nyholm\Psr7\Factory\Psr17Factory;
use Nyholm\Psr7\Response;
use Spiral\RoadRunner\Http\PSR7Worker;
use Spiral\RoadRunner\Worker;

$factory = new Psr17Factory();
$worker = Worker::create();
$psr7 = new PSR7Worker($worker, $factory, $factory, $factory);

while (true) {
    try {
        $request = $psr7->waitRequest();
        if ($request === null) {
            break;
        }

        $path = $request->getUri()->getPath();
        $method = strtoupper($request->getMethod());

        if ($method === 'GET' && $path === '/') {
            $response = new Response(200, ['Content-Type' => 'text/plain; charset=utf-8'], "hello from roadrunner\n");
        } elseif ($method === 'GET' && $path === '/health') {
            $response = new Response(200, ['Content-Type' => 'application/json'], json_encode(['status' => 'ok'], JSON_THROW_ON_ERROR));
        } else {
            $response = new Response(404, ['Content-Type' => 'application/json'], json_encode(['error' => 'not found'], JSON_THROW_ON_ERROR));
        }

        $psr7->respond($response);
    } catch (\Throwable $e) {
        $worker->error((string)$e);

        try {
            $psr7->respond(new Response(500, ['Content-Type' => 'application/json'], '{"error":"internal server error"}'));
        } catch (\Throwable $nested) {
            $worker->error((string)$nested);
            break;
        }
    }
}
