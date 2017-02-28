<!doctype html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="<Project Description>">
<meta name="author" content="Janik von Rotz (http://janikvonrotz.ch)">

<title>{{$title or '<Project Name>'}}</title>

<link rel="stylesheet" href="{{ URL::asset('all.min.css') }}">
@if (App::environment('local'))
    <script src="//localhost:35729/livereload.js"></script>
@endif
</head>

<body>
<div class="container">
