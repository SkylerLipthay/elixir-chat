# Chat

A small chat application written in Elixir that uses TCP for communication.

The client makes use of the [Ratatouille](https://github.com/ndreynolds/ratatouille) library for presenting a text user interface in the terminal.

## Demo

https://github.com/SkylerLipthay/elixir-chat/assets/38674/5c31f24c-1ee6-4569-af4c-aad7acf6a794

## Running

This project requires Python, Erlang, and Elixir, which are most easily installed by asdf (be sure to add the Python, Erlang, and Elixir plugins).

Clone the repository and run the following commands.

```
asdf install
mix deps.get
mix run --no-halt -- server 4000
mix run --no-halt -- client 127.0.0.1 4000
```

## Shortcomings

I wrote this project to learn Elixir. There is limited error handling implemented ("let it crash," huh?), and no tests. Plenty of features you might expect are missing.
